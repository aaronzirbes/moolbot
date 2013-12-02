# Description:
#   App Status returns the application version info from a bloom environment
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot app status - The production app version
#   hubot <host> app status - The app version from a given environment (qa3, uat1, etc...)

dns = require 'dns'

module.exports = (robot) ->

    robot.respond /(.+ )?app status/i, (msg) ->
        host = msg.match[1]
        if host
            hostname = host.trim() + ".moolb.com"
        else
            hostname = "bloomaccount.com"
        uri = "https://" + hostname + "/appStatus"

        dns.lookup hostname, (err, address, family) ->
            if err
                msg.send "Sorry, but #{hostname} isn't really a thing..."
            else
                msg.http(uri)
                    .get() (err, res, body) ->
                        if err
                            msg.send err
                        else
                            data = JSON.parse(body)
                            appVersion = data.appVersion
                            radiantVersion = data.memberService.appVersion
                            buildNumber = data.buildNumber
                            msg.send """#{hostname} is running:
                                * bloomhealth version #{appVersion}
                                * radiant version #{radiantVersion} 
                                * from build number #{buildNumber}"""
