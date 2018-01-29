# Description:
#   List / start / stop ec2 instances on Automic PSL AWS account.  
#
# Commands:
#   ec2 list <search_filter> - Displays Instances
#   ec2 stop <instance_id> - Stops Instance
#   ec2 start <instance_id> - Starts Instance

# Notes:
#   <search_filter>: [optional] The name to be used for filtering the returned instances by instance name.
#   <instance_id>: [mandatory] The EC2 Unique Instance ID (usually starts with "i-", the "i-" is however not mandatory)
#
# Author:
#   Bren Sapience <brendan.sapience@gmail.com>

AWS = require('aws-sdk');

moment = require 'moment'
util   = require 'util'
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

# add "i-" in front of the instance ID if it isnt there
getInstanceID = (InstID) ->
  if /^i-.*$/.test(InstID)
    return InstID
  else
    return "i-"+InstID

module.exports = (robot) ->
  hubotAdapter = robot.adapterName

  # List EC2 Instances
  robot.hear /(?:ec2|aws|amazon)(?: )*(?:list|ls|show|instances)(.*)$/i, (msg) ->

    arg_params = msg.match[1]
    ins_filter = msg.match[1].replace /^\s+|\s+$/g, "" # could be a name, but could also be a status? stopped or running

    StatusFilter = false
    StatusKeyword = ""

    if /start|started|running|active/i.test(ins_filter) then StatusFilter = true; StatusKeyword = "running";
    if /stop|stopped|inactive/i.test(ins_filter) then StatusFilter = true; StatusKeyword = "stopped";
   
    msg_txt = "Fetching all instances"
    if StatusFilter
      msg_txt += " in status: *#{StatusKeyword}*" if ins_filter
    else
      msg_txt += " containing *#{ins_filter}* in name" if ins_filter
    msg_txt += "..."
    msg.send msg_txt

    ec2.describeInstances null, (err, res) ->
      if err
        msg.send "DescribeInstancesError: #{err}"
      else
          messages = []
          for data in res.Reservations
            ins = data.Instances[0]

            name = '[NoName]'
            for tag in ins.Tags when tag.Key is 'Name'
              name = tag.Value
 
            continue if not StatusFilter and ins_filter and name.toUpperCase().indexOf(ins_filter.toUpperCase()) is -1

            if ins.State.Name is "running"
              statuscolor = "#008000"
            if ins.State.Name is 'stopped'
              statuscolor = "#FF0000"
           
            if robot.adapterName is 'rocketchat'
              msgSendMethod = robot.adapter.customMessage
            if robot.adapterName is 'slack'
              msgSendMethod = msg.send

            #msg.send("*#{name}* (*#{ins.State.Name}*) - #{ins.InstanceType} [#{ins.PrivateIpAddress} - #{ins.PublicIpAddress}]")
            #console.log("testing:#{StatusKeyword}: and #{ins.State.Name} ")
            if StatusKeyword != "" and ins.State.Name == StatusKeyword
              msg.send({
                channel: 'gCCmdeFSQJFoLRigB',
                attachments: [
                  {
                    title: "*#{name}* - *#{ins.State.Name}* - #{ins.InstanceId}",
                    text: "\t => #{ins.InstanceType} [#{ins.PrivateIpAddress} - #{ins.PublicIpAddress}]",
                    color: statuscolor
                    #fields: [
                    # {
                    #  "title": "ID: #{ins.InstanceId}"
                    # }
                    #]
                  }
                ]
              });
    #msg.send "Done!"
      

  # Start EC2 Instance 
  robot.hear /(?:ec2|aws|amazon)(?: )*start(?: )*(.*)$/i, (msg) ->
    ins_id_input = msg.match[1]
    ins_id = getInstanceID(ins_id_input)
    msg_txt = "Starting Instance ID #{ins_id}"
    msg.send msg_txt
    params = {
      InstanceIds: [
        ins_id
      ]
      DryRun: false
    }
    # {"StartingInstances":[{"CurrentState":{"Code":0,"Name":"pending"},"InstanceId":"i-0d437271f3a672e9e","PreviousState":{"Code":80,"Name":"stopped"}}]}
    ec2.startInstances params, (err, res) ->
      if err
        msg.send "DescribeInstancesError: #{err}"
      else
        for data in res.StartingInstances
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

  # Stop EC2 Instance
  robot.hear /(?:ec2|aws|amazon)(?: )*stop(?: )*(.*)$/i, (msg) ->
    ins_id_input = msg.match[1]
    ins_id = getInstanceID(ins_id_input)

    msg_txt = "Stopping Instance ID #{ins_id}"
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
        
