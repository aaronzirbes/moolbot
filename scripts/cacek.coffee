
# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot cacek - Reply w/ what's up
#   hubot casek - Reply w/ the correct spelling

module.exports = (robot) ->
  robot.respond /CACEK$/i, (msg) ->
    msg.send "Wassup? Wassup? Wassup? Wassup? Wassup? Wassup? Wassup? Wassup?"

  robot.respond /CASEK$/i, (msg) ->
    msg.send "It's 'Cacek'."

