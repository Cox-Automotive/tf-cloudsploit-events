
variable "SendSignInEvents" {
  description = "Whether console:Signin events should be sent to CloudSploit"
  default = "true"
}

variable "SendACMEvents" {
  description = "Whether acm:* (AWS Certificate Manager) events should be sent to CloudSploit"
  default = "true"
}

variable "SendCloudTrailEvents" {
  description = "Whether cloudtrail:* events should be sent to CloudSploit"
  default = "true"
}

variable "SendConfigEvents" {
  description = "Whether config:* (AWS Config Service) events should be sent to CloudSploit"
  default = "true"
}

variable "SendEC2Events" {
  description = "Whether ec2:* events should be sent to CloudSploit"
  default = "true"
}

variable "SendIAMEvents" {
  description = "Whether iam:* (AWS Identity Access Management) events should be sent to CloudSploit"
  default = "true"
}

variable "SendKMSEvents" {
  description = "Whether kms:* (AWS Key Management Service) events should be sent to CloudSploit"
  default = "true"
}

variable "SendLogsEvents" {
  description = "Whether logs:* (AWS CloudWatch Logs) events should be sent to CloudSploit"
  default = "true"
}

variable "SendRDSEvents" {
  description = "Whether rds:* (AWS Relational Database Service) events should be sent to CloudSploit"
  default = "true"
}

variable "SendRoute53Events" {
  description = "Whether route53:* events should be sent to CloudSploit"
  default = "true"
}

variable "SendSESEvents" {
  description = "Whether ses:* (AWS Simple Email Serivce) events should be sent to CloudSploit"
  default = "true"
}

variable "URLBase" {
  description = "The base URL for the CloudSploit Events API. DO NOT change unless asked by CloudSploit support"
}

variable "Externalid" {
  description = "The External ID used to initially create the AWS account in CloudSploit"
}
