# Description:
#   List ec2 instances on Automic PSL AWS account.  
#
# Commands:
#   ec2 start <instance_id> - Starts Instance

# Notes:
#   <search_filter>: [optional] The name to be used for filtering the returned instances by instance name.
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

  # List EC2 Instances
  robot.hear /(?:ec2|aws|amazon)(?: )*(?:list|ls|show|instances)(.*)$/i, (msg) ->

    arg_params = msg.match[1]
    ins_filter = msg.match[1].replace /^\s+|\s+$/g, "" # could be a name, but could also be a status? stopped or running

    StatusFilter = false
    StatusKeyword = ""

    if /start|started|running|active/i.test(ins_filter) then StatusFilter = true; StatusKeyword = "running";
    if /stop|stopped|inactive/i.test(ins_filter) then StatusFilter = true; StatusKeyword = "stopped";
   
    if StatusFilter
      ins_filter = ""

    msg_txt = "Fetching all instances"
    if StatusFilter
      msg_txt += " in status: *#{StatusKeyword}*"
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
            if (StatusFilter and ins.State.Name == StatusKeyword) or (not StatusFilter)
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
      
