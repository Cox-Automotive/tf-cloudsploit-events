CloudSploit Events via Terraform
=================
This repo is used for configuring the AWS services to support [CloudSploit](https://cloudsploit.com/events) real-time events.

## Requirements

- [Terraform](https://www.terraform.io/)
- AWS account access to create SNS topic, topic policy, topic subscription, and CloudWatch event rules.

## Modules

### aws-cloudsploit-events

This module creates the necessary AWS resources to forward real-time events to CloudSploit. This module configures the following resources:

  - Creates SNS Topic (cloudsploit-sns-$awsaccountid)
  - Creates SNS Topic Policy
  - Creates SNS Topic Subscription to CloudSploit endpoint (https)
  - Creates CloudWatch event rules

Input Variables
---------------
- `SendSignInEvents` - Whether console:Signin events should be sent to CloudSploit (default = "true")
- `SendACMEvents` - Whether acm:* (AWS Certificate Manager) events should be sent to CloudSploit (default = "true")
- `SendCloudTrailEvents` - Whether cloudtrail:* events should be sent to CloudSploit (default = "true")
- `SendConfigEvents` - Whether config:* (AWS Config Service) events should be sent to CloudSploit (default = "true")
- `SendEC2Events` - Whether ec2:* events should be sent to CloudSploit (default = "true")
- `SendIAMEvents` - Whether iam:* (AWS Identity Access Management) events should be sent to CloudSploit (default = "true")
- `SendKMSEvents` - Whether kms:* (AWS Key Management Service) events should be sent to CloudSploit (default = "true")
- `SendLogsEvents` - Whether logs:* (AWS CloudWatch Logs) events should be sent to CloudSploit (default = "true")
- `SendRDSEvents` - Whether rds:* (AWS Relational Database Service) events should be sent to CloudSploit (default = "true")
- `SendRoute53Events` - Whether route53:* events should be sent to CloudSploit (default = "true")
- `SendSESEvents` - Whether ses:* (AWS Simple Email Serivce) events should be sent to CloudSploit (default = "true")
- `URLBase` - The base URL for the CloudSploit Events API. DO NOT change unless asked by CloudSploit support
- `Externalid` - The External ID used to initially create the AWS account in CloudSploit
