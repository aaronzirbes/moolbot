# Description:
#   Command to check ping pong table availability.
#
# Commands:
#   hubot ping ping - Reply with pong table image

module.exports = (robot) ->
  robot.respond /PING PONG$/i, (msg) ->
    msg.send "http://ping:pong@pingpong.moolb.com/pingpongStatus/pingpongstatus.jpg"

