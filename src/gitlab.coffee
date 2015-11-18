# Description
#   Connect hubot to the gitlab api
#
# Dependencies:
#   node-gitlab
#
# Configuration:
#   HUBOT_GITLAB_URL
#   HUBOT_GITLAB_ACCESSKEY
#
# Commands:
#   gitlab list projects - list projects
#   gitlab list users - list users
#   gitlab show project <id> - shows details about a project
#
# Authors:
#   Ryan Southern <rsouthern@sevaa.com>

gitlab = (require 'gitlab')
  url:   process.env.HUBOT_GITLAB_URL
  token: process.env.HUBOT_GITLAB_ACCESSKEY

gitlabList = (msg) ->
  gitlab.projects.all (projects) ->
    message = ""
    for project in projects
      message = message + "#{project.id}: #{project.path_with_namespace}\n"
    msg.send (message)

gitlabListUsers = (msg) ->
  gitlab.users.all (users) ->
    message = ""
    for user in users
      message = message + "#{user.id}: #{user.name}, #{user.email}, State: #{user.state}\n"
    msg.send (message)

gitlabShowProject = (msg) ->
  projectId = msg.match[2]
  message = ""
  gitlab.projects.show projectId, (project) ->
    message = message + "#{project.name_with_namespace}\n#{project.web_url}\nSSH URL: #{project.ssh_url_to_repo}\nHTTP URL #{project.http_url_to_repo}\nCreated: #{project.created_at}\nLast Activity: #{project.last_activity_at}\n"
    if project.description
      message = message + "Description: #{project.description}\n"
  gitlab.projects.members.list projectId, (members) ->
    message = message + "\nMembers:\n"
    for member in members
      message = message + "#{member.name}\n   Access Level: "
      switch member.access_level
        when 10 then message = message + "Guest\n"
        when 20 then message = message + "Reporter\n"
        when 30 then message = message + "Developer\n"
        when 40 then message = message + "Master\n"
        when 50 then message = message + "Owner\n"
    msg.send (message)

module.exports = (robot) ->
  robot.respond /gitlab list projects/i, (msg) ->
    gitlabList(msg)

  robot.respond /gitlab list users/i, (msg) ->
    gitlabListUsers(msg)

  robot.respond /gitlab show project ([\w\.\-_ ]+)(, (.+))?/i, (msg) ->
    gitlabShowProject(msg)

  robot.gitlab = {
    'list projects': gitlabList
    'list users': gitlabListUsers
    'show project': gitlabShowProject
  }