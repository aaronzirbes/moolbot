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

  robot.hear /.*/i, (msg) ->
    if msg.envelope.user.id.toString() == '280317'
      if robot.random([0,1])
        msg.send "The Gospel according to Cacek."
        msg.send "Amen."
