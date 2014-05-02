# Description:
#   Create and manage teams
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot delete all teams    - Delete all existing teams
#   hubot create <name> team  - Creates a team
#   hubot disband <name> team - Delete a team
#   hubot show <name> team    - Show information about a team
#   hubot show teams          - Show existing teams
#   hubot move <name> team to <room> - Sets the home room for a team
#   hubot <person> belongs to/in the <name> team - Add a member to a team
#   hubot show members of/in <name> team - Show the members of a team
#   hubot <name> team knows about <text> - Tag team with keywords extracted from text
#   hubot tag <name> team with <tag>     - Explicitly tag a team with a word
#   hubot notify/tell <name> team <text> - Send a message to a team's home room
#   hubot what is the id for <room_name> room? - find the HipChat JID for a room
#   hubot who knows about <text> - find teams that know about something
# Author:
#   johnrengelman

Util = require "util"
Keywords = require "keyword-extractor"

module.exports = (robot) ->

  class Team

    constructor: (options) ->
      @name = options.name
      @members = options.members or []
      @tags = options.tags or []
      @room = options.room or ""

    addTag: (tag) ->
      @tags.push(tag)

    addMember: (member) ->
      @members.push(member)

    removeTag: (tag) ->
      @tags = @tags.filter (t) -> t isnt tag

    removeMember: (member) ->
      @members = @members.filter (m) -> m isnt member


  class Teams
    teams: ->
      return robot.brain.get("teams") or {}

    update: (teams) ->
      robot.brain.set("teams", teams)

    list: ->
      names = []
      for own team_name, team of @teams()
        names.push(team_name)
      return names

    find: (filter) ->
      teams = []
      for own team_name, team of @teams()
        if filter(team)
          console.log("filter returned true")
          teams.push team
      return teams

    resetAll: ->
      @update({})

    delete: (name) ->
      teams = @teams()
      delete teams[name.toLowerCase()]
      @update(teams)

    get: (name) ->
      teams = @teams()
      team = teams[name.toLowerCase()] or null
      if team?
        return new Team(teams[name.toLowerCase()])
      else
        return null

    create: (name) ->
      team = new Team name: name.toLowerCase()
      teams = @teams()
      teams[name.toLowerCase()] = team
      @update(teams)
      return team

    exists: (name) ->
      return @get(name)?

    save: (team) ->
      teams = @teams()
      teams[team.name] = team
      @update(teams)

    isFromTeamManager: (msg) ->
      return robot.auth.hasRole(msg.envelope.user, 'team-manager')

  robot.Teams = new Teams

  robot.respond /delete all teams/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      robot.Teams.resetAll()
      msg.send "Ok, I've reset all teams"
    else
      msg.send "Sorry, only team-manager can reset teams"

  robot.respond /show teams/i, (msg) ->
    teams = robot.Teams.list()
    msg.send "Teams: \n#{teams.join("\n")}"

  robot.respond /create (["'\w: -_]+) team/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      team_name = msg.match[1].trim()
      if robot.Teams.exists(team_name)
        msg.send "Sorry, team #{team_name} already exists"
      else
        team = robot.Teams.create(team_name)
        msg.send "Created team #{team.name}"
    else
      msg.send "Sorry, only team-manager can create teams"

  robot.respond /disband (["'\w: -_]+) team/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      team_name = msg.match[1].trim()
      if robot.Teams.exists(team_name)
        robot.Teams.delete(team_name)
        msg.send "Deleted team #{team_name}."
      else
        msg.send "Sorry, there is no team #{team_name}"
    else
      msg.send "Sorry, only team-manager can delete teams"

  robot.respond /show (["'\w: -_]+) team/i, (msg) ->
    team_name = msg.match[1].trim()
    if robot.Teams.exists(team_name)
      team_info = Util.inspect(robot.Teams.get(team_name), false, 4)
      msg.send "Team: #{team_name}" + "\n" + team_info
    else
      msg.send "Sorry, I couldn't find team #{team_name}"

  robot.respond /move (["'\w: -_]+) team to (["'\w: -_]+)/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      team_name = msg.match[1].trim()
      if robot.Teams.exists(team_name)
        team = robot.Teams.get(team_name)
        room = msg.match[2].trim()
        team.room = room
        robot.Teams.save(team)
        msg.send "Ok, I moved the #{team_name} team to #{room}"
      else
        msg.send "Sorry, I couldn't find team #{team_name}"
    else
      msg.send "Sorry, only team-manager can add team tags"

  robot.respond /(["'\w: -_]+) belongs (to|in)( the)? (["'\w: -_]+) team/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      team_name = msg.match[4].trim()
      if robot.Teams.exists(team_name)
        team = robot.Teams.get(team_name)
        user_name = msg.match[1].trim()
        user = robot.brain.userForName(user_name)
        if user?
          team.addMember(user.id)
          robot.Teams.save(team)
          msg.send "Ok, #{user.name} [#{user.id}] is now part of #{team_name}"
        else
          msg.send "Sorry, I don't know #{user_name}"
      else
        msg.send "Sorry, I couldn't find team #{team_name}"
    else
      msg.send "Sorry, only team-manager can add members to teams"

  robot.respond /show members? (of|in) (["'\w: -_]+) team/i, (msg) ->
    team_name = msg.match[2].trim()
    if robot.Teams.exists(team_name)
      team = robot.Teams.get(team_name)
      member_names = (robot.brain.userForId(id).name for id in team.members)
      msg.send "Team #{team_name}: " + "\n" + member_names.join("\n")
    else
      msg.send "Sorry, I couldn't find team #{team_name}"

  robot.respond /(["'\w: -_]+) team knows about (["'\w: -_]+)/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      team_name = msg.match[1].trim()
      if robot.Teams.exists(team_name)
        team = robot.Teams.get(team_name)
        tag_text = msg.match[2].trim()
        tags = Keywords.extract(tag_text, {language: 'english', return_changed_case: true})
        for tag in tags
          team.addTag(tag)
        robot.Teams.save(team)
        msg.send "Ok, #{team_name} knows about: \n#{tags.join("\n")}"
      else
        msg.send "Sorry, I couldn't find team #{team_name}"
    else
      msg.send "Sorry, only team-manager can add team tags"

  robot.respond /tag (["'\w: -_]+) team with (["'\w: -_]+)/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      team_name = msg.match[1].trim()
      if robot.Teams.exists(team_name)
        team = robot.Teams.get(team_name)
        tag = msg.match[2].trim()
        team.addTag(tag)
        robot.Teams.save(team)
        msg.send "Ok, I've tagged #{team_name} with: \n#{tag}"
      else
        msg.send "Sorry, I couldn't find team #{team_name}"
    else
      msg.send "Sorry, only team-manager can add team tags"

  robot.respond /(notify|tell) (["'\w: -_]+) team (that )?(["'\w: -_]+)/i, (msg) ->
    team_name = msg.match[2].trim()
    if robot.Teams.exists(team_name)
      team = robot.Teams.get(team_name)
      if team.room?
        message = msg.match[4].trim()
        if message?
          robot.messageRoom(team.room, message)
          msg.send "Ok, I let #{team_name} know for you."
        else
          msg.send "Silence is deadly. Tell me what to say!"
      else
        msg.send "Sorry, #{team_name} is off the grid"
    else
      msg.send "Sorry, I couldn't find team #{team_name}"

  robot.respond /what is the id for( the)? (["'\w: -_]+) room/i, (msg) ->
    if robot.adapterName is "hipchat"
      room_name = msg.match[2].trim()
      robot.adapter.connector.getRooms (err, rooms, stanza) =>
        if rooms
          matching_rooms = (room.jid for room in rooms.filter (r) -> r.name is room_name)
          msg.send "#{room_name} could be:\n#{matching_rooms.join("\n")}"
        else
          msg.send "Couldn't find any rooms"
    else
      msg.send "Sorry, I only know how to do this for HipChat"

  robot.respond /who knows (about )?(["'\w: -_]+)/i, (msg) ->
    text = msg.match[2].trim()
    keywords = Keywords.extract(text, {language: 'english', return_changed_case: true})
    intersection = (a, b) ->
      [a, b] = [b, a] if a.length > b.length
      value for value in a when value in b
    team_has_tag = (team) ->
      return (intersection keywords, team.tags).length > 0
    teams = robot.Teams.find(team_has_tag)
    if teams.length > 0
      msg.send "You should check with: \n#{(team.name for team in teams).join("\n")}"
    else
      msg.send "Sorry, no-one seems to know about that."
