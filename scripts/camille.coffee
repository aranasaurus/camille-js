Util = require 'util'

# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

# Stole this from https://gist.github.com/felixrabe/db88674566e14e413c6f
String::startsWith ?= (s) -> @slice(0, s.length) == s

# Stole this from https://coffeescript-cookbook.github.io/chapters/strings/trimming-whitespace-from-a-string
String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

module.exports = (robot) ->
  robot.karma_increment_responses = [ 
    "yeah!",
    "+1",
    ":+1:",
    "you rock!",
    ":asdf:",
    ":metal:",
    ":sparkling_heart:"
  ]

  robot.karma_decrement_responses = [
    "d'oh!",
    "take that!",
    ":stuck_out_tongue_closed_eyes:",
    "boooo!",
    "-1",
    ":-1:"
  ]

  random = (min, max) -> return Math.floor(Math.random() * (max-min)) + min

  greetings = ['Hi!', 'ohai!', 'Greetings, citizen.', 'Greetings, program.', 'Hiya!']
  greetingRegex =         /(hi|hello|ohai|hai|hey|(?:good )?(mornin'?g?|evenin'?g?)|howdy|hola|ciao|hallo|bonjour|goedemiddag)/i
  greetingRegexWithName = /(hi|hello|ohai|hai|hey|(?:good )?(mornin'?g?|evenin'?g?)|howdy|hola|ciao|hallo|bonjour|goedemiddag)(,? @?camille[\.\!]?)/i
  robot.respond greetingRegex, (res) ->
    res.reply res.random greetings

  robot.hear greetingRegexWithName, (res) ->
    name = res.match[3]
    if (name.toLowerCase().indexOf robot.name.toLowerCase()) > -1
      res.reply res.random greetings

  thanksResponses = ["You're welcome!", "Not a problem.", "No problemo.", "No worries.", "Any time!", "you betcha!", "sure thing!", ":+1:"]
  robot.respond /(thank|gracias|danke).*/i, (res) ->
    welcome = thanksResponses[random(0, thanksResponses.length)]

    if random(0, 100) > 24
      res.reply res.random thanksResponses
    else
      res.send res.random thanksResponses

  robot.hear /thanks?,? (.*)@?camille(.*)/i, (res) ->
    if random(0, 100) > 24
      res.reply res.random thanksResponses
    else
      res.send res.random thanksResponses

  robot.hear /(give|get|gimme|fetch|I'd like|can I have|I can ha(?:s|z)) @?(\S+[^-\s:])?:? ?(a |some )? ?(:?.+:?[^\?\.\!])[\?\.\!]?$/i, (res) ->
    verb = res.match[1]
    target = res.match[2]
    quantifier = res.match[3].trim() if res.match[3]?

    # the above group matches work for the standard "give", "get", "fetch", and "gimme", but for the "I'd like", "can I have", and "I can haz" variants we need to massage the matches a little
    if verb not in ["give", "get", "fetch", "gim"]
      # for the "I'd like" variant the quantifier is in the 2nd group, not the 3rd
      quantifier = res.match[2] if verb is "I'd like"

      # for the "I can haz" variants the quantifier is missing, so fake it
      quantifier = "a" if verb.startsWith "I can ha"

      # all of the variants have a target of the user that sent this message, so fake the target and verb to make these variants work the same way that "give me" would
      verb = "give"
      target = "me"

    if target is "me"
      target = res.message.user.name

    thing = res.match[4]
    thing = "hamburger" if thing in ["cheezeburger", "cheezburger", "cheeseburger"]
    if thing in ["coffee", "beer", "beers", "poop", "shit", "tada", "rocket", "eggplant", "sushi", "doughnut", "cocktail", "sake", "taco", "hamburger", "pizza", "iankeen", "@iankeen", "aranasaurus", "@aranasaurus"]
      thing = thing.replace("@", "")
      thing = ":#{thing}:"
    else if thing[0] isnt ":"
      thing = "\"#{thing}\""

    res.send res.random [
      "#{target}: here's #{quantifier} #{thing}",
      "here, have #{quantifier} #{thing}, #{target}",
      "#{target}: #{thing}",
      "#{target}: #{thing}, I hope it's as delicious as it was difficult to make...",
      "#{target}: #{quantifier} #{thing}, coming right up!"
    ]

  robot.respond /are you (:awake|alive|okay|ok|t?here|alright|alrite)/i, (res) ->
    adjective = res.match[1]
    adjective = "here" if adjective is "there"
    adjective = "alright" if adjective is "alrite"
    res.reply chitChat(res, adjective, true, true)

  robot.respond /how are you/i, (res) ->
    res.reply chitChat(res, "okay", false, false)

  chitChat = (res, adjective, prefixable, useExtras) ->
    contextualResponse = "I'm here."
    switch adjective
      when "awake"
        contextualResponse = res.random [
          "I'm up!",
          "I'm awake!",
          "I'm here!",
          "I'm still kickin'!",
          "I'm up! I'm up!"
        ]
        contextualResponse = res.random ["Yep, #{contextualResponse}", contextualResponse] if prefixable
      when "alive"
        contextualResponse = res.random [
          "I'm alive.",
          "I'm here.",
          "I'm still kickin'!",
          "I'm not _dead_..."
        ]
        contextualResponse = res.random ["Yep, #{contextualResponse}", "Well... #{contextualResponse}", contextualResponse] if prefixable
        contextualResponse = makeTheFeelingMutual(res, contextualResponse)
      when "okay", "ok", "alright"
        contextualResponse = res.random [
          "I'm #{adjective}.",
          "I'm good.",
          "I'm great!",
          "I've been better...",
          "I'm fine.",
          "Never better!"
        ]
        contextualResponse = res.random [
          contextualResponse,
          "Yep, #{contextualResponse}",
          "Yep! #{contextualResponse}",
          "Hmm, #{contextualResponse}"
        ] if prefixable
        contextualResponse = makeTheFeelingMutual(res, contextualResponse)
      when "here"
        contextualResponse = res.random [
          "I'm here!", "I'm here.",
          "Right here!",
          "Here!",
          "Reporting for duty!"
        ]
        contextualResponse = res.random [
          contextualResponse,
          "Yep, #{contextualResponse}",
          "Yep! #{contextualResponse}"
        ] if prefixable

    contextualResponse = res.random [
      "yep!",
      "yep",
      "yes!",
      "yes",
      "How can I help you?",
      "What can I do for you?",
      "pip pip!",
      "yo",
      "yo.",
      "yo!",
      contextualResponse,
      contextualResponse,
      contextualResponse,
      contextualResponse,
      contextualResponse,
      contextualResponse,
      contextualResponse,
      contextualResponse,
      contextualResponse,
      contextualResponse,
      contextualResponse
    ] if useExtras
    return contextualResponse

  makeTheFeelingMutual = (res, response) ->
    return res.random [
      response,
      "#{response} How're you?",
      "#{response} How are you?",
      "#{response} How've you been?",
      "#{response} How have you been?",
      "#{response} How bout you?",
      "#{response} How 'bout you?",
      "#{response} How about you?",
      "#{response} How you doin?",
      "#{response} How are you doing?",
      "#{response} You?",
      "#{response} And you?"
    ]


  # robot.hear /badger/i, (res) ->
  #   res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
