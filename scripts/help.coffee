# Description:
#   Last asks Hubot to repeat the last command he received
#
# Commands:
#   hubot !! - execute the last received command
#   hubot last - execute the last received command
#   hubot repeat - execute the last received command

Robot = require('hubot')

getReleaseNotes = (message) ->
  message += " *Jan 29 - 2018*: _you can now register 1 Instance ID as your favorite (you then no longer have to specify which instance to start or stop)_\n"
  message += " *Jan 29 - 2018*: _can list based on status (active, inactive, stopped, running)_\n"
  message += " *Jan 26 - 2018*: _First Release: ec2 instance list, start & stop_\n"

getMisc = (message) ->
  message += "\n\n *Repeast Last Command*: _!!_\n"
  message += "\n\n *Show Release Notes*: _<get|show> notes_\n"


getHelpEC2 = (message) -> 
  message += "\t*EC2 Help*\n"
  message += "\n\t\t *Get List of Current EC2 Instances*: _ec2 ls <Optional: Tag or Status (inactive, active, running, stopped)>_ \n"
  message += "\t\t\t*Example*: say: \"_ec2 ls_\" \n" 
  message += "\t\t\t*Example*: say: \"_ec2 ls Dave_\" \n" 
  message += "\t\t\t*Example*: say: \"_ec2 ls active_\" \n" 
  message += "\t\t\t*Example*: say: \"_ec2 ls inactive_\" \n"

  message += "\n\t\t *Make an Instance ID your Favorite*: _memorize id <InstanceID>_ \n"
  message += "\t\t\t*Example*: say: \"_memorize id i-sdfjk23k345lkh_\" \n" 

  message += "\n\t\t *Start or Stop EC2 Instance By ID*: _ec2 <start|stop> <InstanceID>_ \n"
  message += "\t\t\t*Example*: say: \"_ec2 start 0650920f52db7fbe0_\" \n" 
  message += "\t\t\t*Example*: say: \"_ec2 start i-0650920f52db7fbe0_\" \n" 
  message += "\t\t\t*Example*: say: \"_ec2 stop i-0650920f52db7fbe0_\" \n"

  message += "\n\t\t *Start or Stop your Favorite EC2 Instance*: _ec2 <start|stop>_ \n"
  message += "\t\t\t*Example*: say: \"_ec2 start_\" \n" 
  message += "\t\t\t*Example*: say: \"_ec2 stop_\" \n"

module.exports = (robot) ->

  robot.respond /(?:help)(?: )*(?:me)*.*/i, (msg) ->
    message = ""
    msg.reply getHelpEC2(message)
    msg.reply getMisc(message)

  robot.respond /(?:get|show)(?: )*(?:notes|note|release note|releast notes).*/i, (msg) ->
    message = ""
    msg.reply getReleaseNotes(message)

