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
#   hubot create team <name> - Creates a team with the name
#   hubot delete team <name> - Delete a team with the name
#   hubot show teams         - Show existing teams
# Author:
#   johnrengelman

Util = require "util"

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
      for own team_name, teams of @teams()
        names.push(team_name)
      return names

    resetAll: ->
      @update({})

    delete: (name) ->
      teams = @teams()
      delete teams[name]
      @update(teams)

    get: (name) ->
      teams = @teams()
      team = teams[name] or null
      if team?
        return new Team(teams[name])
      else
        return null

    create: (name) ->
      team = new Team name: name
      teams = @teams()
      teams[name] = team
      @update(teams)

    exists: (name) ->
      return @get(name)?

    save: (team) ->
      teams = @teams()
      teams[team.name] = team
      @update(teams)

    isFromTeamManager: (msg) ->
      return robot.Auth.hasRole(msg.message.user, 'team-manager')

  robot.Teams = new Teams

  robot.respond /delete all teams/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      robot.Teams.resetAll()
      msg.send "Ok, I've reset all teams"
    else
      msg.send "Sorry, only team-manager can reset teams"

  robot.respond /show teams/i, (msg) ->
    teams = robot.Teams.list()
    msg.send "Teams: #{teams.join(", ")}"

  robot.respond /create team (["'\w: -_]+)/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      team_name = msg.match[1].trim()
      if robot.Teams.exists(team_name)
        msg.send "Sorry, team #{team_name} already exists"
      else
        robot.Teams.create(team_name)
      msg.send "Created team #{team_name}."
    else
      msg.send "Sorry, only team-manager can create teams."

  robot.respond /delete team (["'\w: -_]+)/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      team_name = msg.match[1].trim()
      if robot.Teams.exists(team_name)
        robot.Teams.delete(team_name)
        msg.send "Deleted team #{team_name}."
      else
        msg.send "Sorry, there is no team #{team_name}"
    else
      msg.send "Sorry, only team-manager can delete teams."

  robot.respond /show team (["'\w: -_]+)/i, (msg) ->
    team_name = msg.match[1].trim()
    if robot.Teams.exists(team_name)
      team_info = Util.inspect(robot.Teams.get(team_name), false, 4)
      msg.send "Team: #{team_name}" + "\n" + team_info
    else
      msg.send "Sorry, I couldn't find team #{team_name}"

  robot.respond /team (["'\w: -_]+) lives in (["'\w: -_]+)/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      team_name = msg.match[1].trim()
      if robot.Teams.exists(team_name)
        team = robot.Teams.get(team_name)
        room = msg.match[2].trim()
        team.room = room
        robot.Teams.save(team)
        msg.send "Ok, moved #{team_name} to #{room}"
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

  robot.respond /tag team (["'\w: -_]+) with (["'\w: -_]+)/i, (msg) ->
    if robot.Teams.isFromTeamManager(msg)
      team_name = msg.match[1].trim()
      if robot.Teams.exists(team_name)
        team = robot.Teams.get(team_name)
        tag = msg.match[2].trim()
        team.addTag(tag)
        robot.Teams.save(team)
        msg.send "Ok, #{team_name} knows about #{tag}"
      else
        msg.send "Sorry, I couldn't find team #{team_name}"
    else
      msg.send "Sorry, only team-manager can add team tags"

  robot.respond /notify (["'\w: -_]+) team (["'\w: -_]+)/i, (msg) ->
    team_name = msg.match[1].trim()
    if robot.Teams.exists(team_name)
      team = robot.Teams.get(team_name)
      if team.room?
        message = msg.match[2].trim()
        if message?
          robot.messageRoom(team.room, message)
          msg.send "Ok, I let #{team_name} know."
        else
          msg.send "Silence is deadly. Tell me what to say!"
      else
        msg.send "Sorry, #{team_name} is off the grid."
    else
      msg.send "Sorry, I couldn't find team #{team_name}"

  robot.respond /What is the id for (["'\w: -_]+) room/i, (msg) ->
    if robot.adapterName is "hipchat"
      room_name = msg.match[1].trim()
      robot.adapter.connector.getRooms (err, rooms, stanza) =>
        if rooms
          matching_rooms = (room.jid for room in rooms.filter (r) -> r.name is room_name)
          msg.send "#{room_name} could be #{matching_rooms}"
        else
          msg.send "Couldn't find any rooms"
    else
      msg.send "Sorry, I only know how to do this for HipChat"
