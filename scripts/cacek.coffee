# Description:
#   All about Michael.
#
# Commands:
#   hubot cacek - Reply w/ what's up
#   hubot casek - Reply w/ the correct spelling
#   hubot reset all cacek - Reset Cacek counters everywhere
#   hubot reset cacek - Reset Cacek counter in this room

quotes = [
  "The Gospel according to Cacek. Amen.",
  "Preach, Cacek! Preach!",
  "Can Cacek get an Amen?!",
  "Hallelujah! Hallelujah!",
  "Say it again, Cacek, I don't think they heard you!",
]

module.exports = (robot) ->

  class Cacek
    constructor: (options) ->
      @max = options.max or 100
      @default = options.default or 25
      @min = 0
      @rooms = []

    resetAll: ->
      @rooms = []

    reset: (msg) ->
      @rooms[msg.envelope.room] = @default

    inc: (msg) ->
        current = @rooms[msg.envelope.room] || @default
        if current < @max
          @rooms[msg.envelope.room] = ++current

    dec: (msg) ->
        current = @rooms[msg.envelope.room] || @default
        if current > @min
          @rooms[msg.envelope.room] = --current

    test: (msg) ->
      current = @rooms[msg.envelope.room] || @default
      Math.random() < (current / @max)

  robot.cacek = new Cacek({})

  robot.respond /reset all cacek/i, (msg) ->
    robot.cacek.resetAll()
    msg.send("Ok, I reset Cacek everywhere.")

  robot.respond /reset cacek/i, (msg) ->
    robot.cacek.reset(msg)
    msg.send("Ok, I reset Cacek in this room.")

  robot.hear /CACEK$/i, (msg) ->
    msg.send "Wassup? Wassup? Wassup? Wassup? Wassup? Wassup? Wassup? Wassup?"

  robot.hear /CASEK$/i, (msg) ->
    msg.send "It's 'Cacek'."

  robot.hear /./i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'the-cacek')
      robot.cacek.inc(msg)
      if robot.cacek.test(msg)
        msg.send msg.random(quotes)
    else
      robot.cacek.dec(msg)
