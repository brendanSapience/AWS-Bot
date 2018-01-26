# Description:
#   List ec2 instances on your AWS account.  
#
# Commands:
#   hubot ec2 ls <search_filter> - Displays Instances

# Notes:
#   <search_filter>: [optional] The name to be used for filtering the returned instances by instance name.
#
# Author:
#   John Szaszvari <jszaszvari@gmail.com>

AWS = require('aws-sdk');

moment = require 'moment'
util   = require 'util'
tsv    = require 'tsv'

AUTOMICAWSACCESSKEY = process.env.AUTOMICAWSACCESSKEY
AUTOMICAWSSECRETKEY = process.env.AUTOMICAWSSECRETKEY
AUTOMICAWSREGION = process.env.AUTOMICAWSREGION

AWS.config.update({
    accessKeyId: AUTOMICAWSACCESSKEY,
    secretAccessKey: AUTOMICAWSSECRETKEY,
    "region": AUTOMICAWSREGION
})
console.log(AUTOMICAWSACCESSKEY)
ec2 = new AWS.EC2()

getArgParams = (arg) ->
  ins_id_capture = /--instance_id=(.*?)( |$)/.exec(arg)
  ins_id = if ins_id_capture then ins_id_capture[1] else ''


  # filter by instance name
  #ins_filter_capture = /--instance_filter=(.*?)( |$)/.exec(arg)
  #ins_filter_capture = arg[1]

  #ins_filter = if ins_filter_capture then ins_filter_capture[1] else ''

  return {
    ins_id: ins_id,
   # ins_filter: ins_filter
  }
module.exports = (robot) ->
  hubotAdapter = robot.adapterName

  robot.hear /ec2 ls(.*)$/i, (msg) ->

    arg_params = getArgParams(msg.match[1])
    ins_id  = arg_params.ins_id
    ins_filter = msg.match[1].replace /^\s+|\s+$/g, ""
   
    msg_txt = "Fetching #{ins_id || 'all instances'}"
    msg_txt += " containing '#{ins_filter}' in name" if ins_filter
    msg_txt += "..."
    msg.send msg_txt

    ec2.describeInstances (if ins_id then { InstanceIds: [ins_id] } else null), (err, res) ->
      if err
        msg.send "DescribeInstancesError: #{err}"
      else
        if ins_id
          msg.send util.inspect(res, false, null)

          ec2.describeInstanceAttribute { InstanceId: ins_id, Attribute: 'userData' }, (err, res) ->
            if err
              msg.send "DescribeInstanceAttributeError: #{err}"
            else if res.UserData.Value
              msg.send new Buffer(res.UserData.Value, 'base64').toString('ascii')
        else
          messages = []
          for data in res.Reservations
            ins = data.Instances[0]

            name = '[NoName]'
            for tag in ins.Tags when tag.Key is 'Name'
              name = tag.Value

            continue if ins_filter and name.indexOf(ins_filter) is -1

            if ins.State.Name is "running"
              statuscolor = "#008000"
            if ins.State.Name is 'stopped'
              statuscolor = "#FF0000"
           
            if robot.adapterName is 'rocketchat'
              msgSendMethod = robot.adapter.customMessage
            if robot.adapterName is 'slack'
              msgSendMethod = msg.send

            #msg.send("*#{name}* (*#{ins.State.Name}*) - #{ins.InstanceType} [#{ins.PrivateIpAddress} - #{ins.PublicIpAddress}]")
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
      

            
  robot.hear /ec2 start(?: )*(.*)$/i, (msg) ->
    ins_id = msg.match[1]
   
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
        console.log(JSON.stringify(res))



  robot.hear /ec2 stop(?: )*(.*)$/i, (msg) ->
    ins_id = msg.match[1]
   
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
        console.log(JSON.stringify(res))
