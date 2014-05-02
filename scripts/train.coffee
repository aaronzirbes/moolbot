# Description:
#   None
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   train - Choo Choo!
#   lunch train - yum
#   hh train - thirsty
#
# Author:
#   johnrengelman

trains = [
  "Choo! Choo!",
  "I think I can. I think I can. I think I can.",
  "Train don't run out of Wichita... unlessin' you're a hog or a cattle.",
  "All aboard! Hahaha",
  "I'm goin' off the rails on a crazy train",
]

module.exports = (robot) ->
  robot.hear /(lunch )?(hh )?train\b/i, (msg) ->
    if not msg.match[1] and not msg.match[2]
      msg.send msg.random trains

  robot.hear /lunch train\b/i, (msg) ->
    msg.send "Next stop, Lunch!"

  robot.hear /hh train\b/i, (msg) ->
    msg.send "Next stop, Lyon's!"
