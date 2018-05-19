# Description:
#   Stop ec2 instances on Automic PSL AWS account.  
#
# Commands:
#   ec2 stop <instance_id> - Stops Instance

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

  # Stop EC2 Instance
  robot.hear /(?:ec2|aws|amazon)(?: )*stop(?: )*(.*)$/i, (msg) ->
    ins_id_input = msg.match[1]
    if ins_id_input == ""
      ins_id = utils.getInstanceIDFromMemory(robot,msg)
      msg_txt = " => Retrieving Instance ID from Memory.. Found: *#{ins_id}* \n"
    else
      ins_id = utils.getInstanceID(ins_id_input)
      msg_txt = ""

    msg_txt = msg_txt + "Stopping Instance ID *#{ins_id}*"
    msg.send msg_txt
    params = {
      InstanceIds: [
        ins_id
      ]
      DryRun: false
    }
    # {"StoppingInstances":[{"CurrentState":{"Code":64,"Name":"stopping"},"InstanceId":"i-0d437271f3a672e9e","PreviousState":{"Code":16,"Name":"running"}}]}
    ec2.stopInstances params, (err, res) ->
      if err
        msg.send "DescribeInstancesError: #{err}"
      else
        #console.log(JSON.stringify(res))
        for data in res.StoppingInstances
          NewStatus = data.CurrentState.Name
          OldStatus = data.PreviousState.Name
          msg.send({
              channel: 'gCCmdeFSQJFoLRigB',
              attachments: [
                {
                  color: "#439FE0",
                  #title: "Status Change",
                  pretext: "Status Change for Instance #{ins_id}",
                  fields: [
                   {
                    "title": "New Status",
                    "value": "#{NewStatus}",
                    "short" : true
                   },                   
                   {
                    "title": "Previous Status",
                    "value": "#{OldStatus}",
                    "short" : true
                   }
                  ]
                }
              ]
            });
        
