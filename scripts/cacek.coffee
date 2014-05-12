# Description:
#   All about Michael.
#
# Commands:
#   hubot cacek - Reply w/ what's up
#   hubot casek - Reply w/ the correct spelling

module.exports = (robot) ->
  robot.hear /CACEK$/i, (msg) ->
    msg.send "Wassup? Wassup? Wassup? Wassup? Wassup? Wassup? Wassup? Wassup?"

  robot.hear /CASEK$/i, (msg) ->
    msg.send "It's 'Cacek'."

  robot.hear /./i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'the-cacek')
      if msg.random([true, false])
        msg.send "The Gospel according to Cacek."
        msg.send "Amen."
