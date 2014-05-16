# Description:
#   Watch rooms for Jenkins build failures and notify commiters.
#
# Configuration:
#   HUBOT_JENKINS_USERS - A comma separate list of user IDs to watch
#   JENKINS_AUTH - username:apitoken for Jenkins Auth
#
# Author
#   jengelman

module.exports = (robot) ->

  unless process.env.HUBOT_JENKINS_USERS?
    robot.logger.warning 'The HUBOT_JENKINS_USERS environment variable not set'

  if process.env.HUBOT_JENKINS_USERS?
    jenkins = process.env.HUBOT_JENKINS_USERS.split ','
  else
    jenkins = []

  if process.env.JENKINS_AUTH?
    auth = process.env.JENKINS_AUTH

  robot.hear /FAILURE .* href="http:\/\/(.*?)"/, (msg) ->
    if msg.envelope.user.id.toString() in jenkins
      job_info = "http://"
      if auth
        job_info += (auth + '@')
      job_info += "#{msg.match[1]}api/json"
      msg.http(job_info)
        .get() (err, res, body) ->
          try
            json = JSON.parse(body)
            culprits = (culprit.fullName for culprit in json.culprits)
            for culprit in culprits
              user = robot.brain.userForName(culprit)
              if not user
                console.log("Could not find user for [#{culprit}]")
                msg.send("Can't notify culprit [#{culprit}]")
              else
                msg.send(user, "Hey jerk, looks like you may have had a hand in breaking a build: http://#{msg.match[1]}")
          catch error
            console.log("error parsing #{body}")
