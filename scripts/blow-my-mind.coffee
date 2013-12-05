# Description:
#   Utility commands for blowing your mind
#
# Commands:
#   hubot blow my mind - img

module.exports = (robot) ->
  robot.respond /blow my mind/i, (msg) ->
    msg.send "http://i.imgur.com/D3lON.gif"