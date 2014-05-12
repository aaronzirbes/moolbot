# Description:
#   All about Michael.
#
# Commands:
#   hubot cacek - Reply w/ what's up
#   hubot casek - Reply w/ the correct spelling

module.exports = (robot) ->
  robot.respond /CACEK$/i, (msg) ->
    msg.send "Wassup? Wassup? Wassup? Wassup? Wassup? Wassup? Wassup? Wassup?"

  robot.respond /CASEK$/i, (msg) ->
    msg.send "It's 'Cacek'."

  robot.hear /./i, (msg) ->
    console.log("Testing for Cacek", robot.auth.hasRole(mas.envelope.user, 'the-cacek'))
    if robot.auth.hasRole(msg.envelope.user, 'the-cacek')
      console.log("From The Cacek")
      if robot.random([true, false])
        console.log("Responding")
        msg.send "The Gospel according to Cacek."
        msg.send "Amen."
      else
        console.log("Not Responding")
