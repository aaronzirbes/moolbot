# Description:
#   timer (see https://gist.github.com/saihoooooooo/5828308)
#
# Commands:
#   hubot timer <int> [<text>] - <int> number of seconds <text> message

module.exports = (robot) ->
  robot.respond /timer (\d+) ?(.+)?/i, (msg) ->
    time = msg.match[1] * 1000
    text = msg.match[2] ? 'Ding ding ding ding ding!'
    setTimeout ->
      msg.send text
    , time
