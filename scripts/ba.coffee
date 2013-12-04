# Description:
#   Beer Advocate beer information
#
# Dependencies:
#   None
#
# Configuration:
#
# Commands:
#   hubot ba me <beer name> - Information about a beer
#
# Author:
#   boggebe

module.exports = (robot) ->
    robot.respond /ba me (.*)/i, (msg) ->
        msg.http("http://beeradvocate.com/search")
            .query
                qt: "beer"
                retired: "N"
                q: msg.match[1].replace(" ", "+")
            .get() (err, res, body) ->
                if (res.statusCode == 200)
                    # get first search result
                    reg = /<a href="\/beer\/profile\/(.+?)\/(.+?)">(.+?)<\/a>/i
                    results = body.match(reg)

                    if (results != null && results.length > 3)
                        msg.http("http://beeradvocate.com/beer/profile/" + results[1] + "/" + results[2])
                            .get() (err, res, body) ->

                                # get all tds
                                beer_name = body.match(/<h1>(.+?)<span.+>/)[1]
                                tds = body.match(/<td.+>([\s\S]+?)<\/td>/ig)
                                # ratings_info = tds[3]
                                
                                response = beer_name

                                beer_info_td = tds[4]
                                brewery = beer_info_td.match(/<a href="\/beer\/profile\/.+"><b>(.+?)<\/b>/i)[1]
                                state = beer_info_td.match(/<a href="\/beerfly\/directory\/.+?">(.+?)<\/a>/i)[1]
                                country = beer_info_td.match(/<a href="\/beerfly\/directory\/.+">(.+?)<\/a>/i)[1]
                                style = beer_info_td.match(/<a href="\/beer\/style\/.+"><b>(.+?)<\/b>/i)[1]
                                abv_result = beer_info_td.match(/\| &nbsp;(.+?%)/i)
                                abv = '?'
                                if (abv_result != null)
                                    abv = abv_result[1]

                                response += " (" + brewery + ")\n"
                                response += state + ", " + country + "\n"
                                response += style + " | " + abv + " ABV\n"

                                ba_score_td = tds[1]
                                ba_score = ba_score_td.match(/<span class="BAscore_big">(.+?)<\/span>/i)[1]
                                response += "BA Score: " + ba_score + "\n"

                                bros_score_td = tds[2]
                                bros_score = bros_score_td.match(/<span class="BAscore_big">(.+?)<\/span>/i)[1]
                                response += "Bro's Score: " + bros_score
                                
                                image_td = tds[0]
                                image_url = "http://beeradvocate.com" + image_td.match(/<img src="(.+?)"/i)[1]

                                msg.send response
                                msg.send image_url
                    else
                        msg.send "I have no idea what you're talking about."
                                