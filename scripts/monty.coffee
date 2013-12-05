# Description:
#   Utility commands surrounding Monty app
#
# Commands:
#   hubot monty me - link to monty.moolb.com

module.exports = (robot) ->
  robot.respond /monty me/i, (msg) ->
    msg.send "http://monty.moolb.com/"