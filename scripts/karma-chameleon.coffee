# Description:
#   Track arbitrary karma
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   <thing>++ - give thing some karma
#   <thing>-- - take away some of thing's karma
#   hubot karma <thing> - check thing's karma (if <thing> is omitted, show the top 5)
#   hubot karma empty <thing> - empty a thing's karma
#   hubot karma best [n] - show the top n (default: 5)
#   hubot karma worst [n] - show the bottom n (default: 5)
#
# Contributors:
#   D. Stuart Freeman (@stuartf) https://github.com/stuartf
#   Andy Beger (@abeger) https://github.com/abeger


class Karma

  constructor: (@robot) ->
    @cache = {}

    @increment_responses = @robot.karma_increment_responses ? [
      "+1!", "gained a level!", "is on the rise!", "leveled up!"
    ]

    @decrement_responses = @robot.karma_decrement_responses ? [
      "took a hit! Ouch.", "took a dive.", "lost a life.", "lost a level."
    ]

    @cheat_responses = @robot.karma_cheat_responses ? [
      "Nice try.", "Do you really think that I'm _that_ stupid?", "This is some next-level narcissism."
    ]

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.karma
        @cache = @robot.brain.data.karma

  clear: (thing) ->
    delete @cache[thing]
    @robot.brain.data.karma = @cache

  increment: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] += 1
    @robot.brain.data.karma = @cache

  decrement: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] -= 1
    @robot.brain.data.karma = @cache

  incrementResponse: ->
    @increment_responses[Math.floor(Math.random() * @increment_responses.length)]

  decrementResponse: ->
    @decrement_responses[Math.floor(Math.random() * @decrement_responses.length)]

  cheatResponse: ->
    @cheat_responses[Math.floor(Math.random() * @cheat_responses.length)]

  get: (thing) ->
    k = if @cache[thing] then @cache[thing] else 0
    return k

  sort: ->
    s = []
    for key, val of @cache
      s.push({ name: key, karma: val })
    s.sort (a, b) -> b.karma - a.karma

  top: (n = 5) =>
    sorted = @sort()
    sorted.slice(0, n)

  bottom: (n = 5) =>
    sorted = @sort()
    sorted.slice(-n).reverse()

module.exports = (robot) ->
  karma = new Karma robot

  nameREString = "(@|:)(\\S+[^+:\\s])(:?|: )?"

  ###
  # Listen for "++" messages and increment
  ###
  robot.hear new RegExp("#{nameREString}\\+\\+(\s|$)"), (msg) ->
    subject = msg.match[2].toLowerCase().replace(':', '')
    sender = msg.user.name

    # Check if the user tried to change his/her own karma level
    if subject is sender
      msg.send "#{karma.cheatResponse()}"
    else
      karma.increment subject
      msg.send "#{subject} #{karma.incrementResponse()} (Karma: #{karma.get(subject)})"

  ###
  # Listen for "--" messages and decrement
  ###
  robot.hear new RegExp("#{nameREString}--(\s|$)"), (msg) ->
    subject = msg.match[2].toLowerCase().replace(':', '')
    # avoid catching HTML comments
    unless subject[-2..] == "<!"
      karma.decrement subject
      msg.send "#{subject} #{karma.decrementResponse()} (Karma: #{karma.get(subject)})"

  ###
  # Listen for "karma clear x" and empty x's karma
  ###
  robot.respond /karma clear ?@?(\S+[^-\s:]):?$/i, (msg) ->
    subject = msg.match[1].toLowerCase()
    karma.clear subject
    msg.send "#{subject} has had its karma scattered to the winds."

  ###
  # Function that handles best and worst list
  # @param msg The message to be parsed
  # @param title The title of the list to be returned
  # @param rankingFunction The function to call to get the ranking list
  ###
  parseListMessage = (msg, title, rankingFunction) ->
    count = if msg.match.length > 1 then msg.match[1] else null
    verbiage = [title]
    if count?
      verbiage[0] = verbiage[0].concat(" ", count.toString())
    for item, rank in rankingFunction(count)
      verbiage.push "#{rank + 1}. #{item.name} - #{item.karma}"
    msg.send verbiage.join("\n")

  ###
  # Listen for "karma best [n]" and return the top n rankings
  ###
  robot.respond /karma best\s*(\d+)?$/i, (msg) ->
    parseData = parseListMessage(msg, "The Best", karma.top)

  ###
  # Listen for "karma worst [n]" and return the bottom n rankings
  ###
  robot.respond /karma worst\s*(\d+)?$/i, (msg) ->
    parseData = parseListMessage(msg, "The Worst", karma.bottom)

  ###
  # Listen for "karma x" and return karma for x
  ###
  robot.respond /karma ?@?(\S+[^-\s:]):?$/i, (msg) ->
    sendKarmaResponse(msg)

  robot.respond /how (?:much|many) (?:karma ?-?)?(?:points)? does @?(\S+[^-\s:]):? have\??/i, (msg) ->
    sendKarmaResponse(msg)

  sendKarmaResponse = (msg) ->
    match = msg.match[1].toLowerCase()
    if not (match in ["best", "worst"])
      msg.send "\"#{match}\" has #{karma.get(match)} karma."

