# AWS-bot

AWS-bot is a chat bot built on the [Hubot][hubot] framework.

### Purpose:

Easily manage EC2 Instances used by the US Presales team for CA | Automic

### Configuration

The AWS account information are passed at runtime as environment variables
This uses the aws-sdk node.js module (the standard one)

### Features

Currently limited to list / start / stop of EC2 instances:


    ec2 list
    ec2 list Mark
    ec2 list Active
    ec2 list Inactive

    ec2 stop i-wefkjhj3453768
    ec2 stop wefkjhj3453768

    ec2 start i-sdfsdfl345345d
    ec2 start sdfsdfl345345d
