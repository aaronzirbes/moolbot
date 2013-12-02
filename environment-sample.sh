heroku addons:add redistogo:nano
app_name=`git remote -v | grep heroku |grep push |sed -e 's/.*heroku.com://' -e 's/.git (.*//'`
heroku config:add HEROKU_URL=http://${app_name}.herokuapp.com
heroku config:add HUBOT_HIPCHAT_JID="SOMEJABBERID@chat.hipchat.com"
heroku config:add HUBOT_HIPCHAT_PASSWORD="BLAHBLAH"
