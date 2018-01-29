# Description:
#   start ec2 instances on Automic PSL AWS account.  
#
# Commands:
#   ec2 start <instance_id> - Starts Instance

# Notes:
#   <instance_id>: [mandatory] The EC2 Unique Instance ID (usually starts with "i-", the "i-" is however not mandatory)
#
# Author:
#   Bren Sapience <brendan.sapience@gmail.com>

AWS = require('aws-sdk');

moment = require 'moment'
utils   = require './utils'
tsv    = require 'tsv'

# AWS Creds are stored as Environment Variables
AUTOMICAWSACCESSKEY = process.env.AUTOMICAWSACCESSKEY
AUTOMICAWSSECRETKEY = process.env.AUTOMICAWSSECRETKEY
AUTOMICAWSREGION = process.env.AUTOMICAWSREGION

AWS.config.update({
    accessKeyId: AUTOMICAWSACCESSKEY,
    secretAccessKey: AUTOMICAWSSECRETKEY,
    "region": AUTOMICAWSREGION
})

ec2 = new AWS.EC2()

module.exports = (robot) ->
  hubotAdapter = robot.adapterName

  # Memorize EC2 Instance 
  robot.hear /(?:memorize|remember|mark|flag)(?: )*(?:my id|id|this|this id|the|the id|instance)(?: )*(.*)/i, (msg) ->
    ins_id_raw = msg.match[1]
    ins_id = utils.getInstanceID(ins_id_raw)
    username = msg.message.user.name
    Key = username+"_FavoriteAWSIns"
    robot.brain.set "#{Key}",ins_id
    msg_txt = "K, I'll remember your *favorite instance* as: *#{ins_id}*"
    msg.send msg_txt

  # Get Favorite EC2 Instance 
  robot.hear /test/i, (msg) ->
    username = msg.message.user.name
    Key = username+"_FavoriteAWSIns"
    FoundID = robot.brain.get "#{Key}"
    if FoundID
      msg_txt = "Here is the instance ID I found for you: *#{FoundID}*"
    else
      msg_txt = "Looks like there is no Instance ID Memorized for you."
    msg.send msg_txt