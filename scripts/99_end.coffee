# Description:
#   Last asks Hubot to repeat the last command he received
#
# Commands:
#   hubot !! - execute the last received command
#   hubot last - execute the last received command
#   hubot repeat - execute the last received command

Robot = require('hubot')

module.exports = (robot) ->

  robot.respond /!!/i, (msg) ->
    if robot.brain.data.last_command
      robot.receive new Robot.TextMessage(msg.message.user, robot.brain.data.last_command, msg.id)
    else
      msg.send "No last command in mah memories"

  robot.respond /(?!.*(!!|last|repeat))(.*)/i, (msg) ->
    robot.brain.data.last_command = msg.match[0]