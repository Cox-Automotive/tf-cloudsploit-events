data "aws_caller_identity" "current" { }

data "aws_region" "current" { current = true }

output "aws_account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

# Creates the SNS Topic
resource "aws_sns_topic" "cloudsploit-sns-topic" {
  name = "cloudsploit-sns-${data.aws_caller_identity.current.account_id}"
  display_name = "cloudsploit-sns-${data.aws_caller_identity.current.account_id}"
}

# Creates the SNS Topic Policy
resource "aws_sns_topic_policy" "cloudsploit-sns-policy" {
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "cspolicy",
  "Statement":[
    {
    "Sid": "__default_statement_ID",
    "Effect": "Allow",
    "Principal": {
      "AWS":"*"
    },
    "Action": [
      "SNS:Publish",
			"SNS:RemovePermission",
			"SNS:SetTopicAttributes",
			"SNS:DeleteTopic",
			"SNS:ListSubscriptionsByTopic",
			"SNS:GetTopicAttributes",
			"SNS:Receive",
			"SNS:AddPermission",
			"SNS:Subscribe"
    ],
    "Resource": "${aws_sns_topic.cloudsploit-sns-topic.arn}",
    "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "${data.aws_caller_identity.current.account_id}"
        }
    }
  },
  {
    "Sid": "__console_pub_0",
    "Effect": "Allow",
    "Principal": {
      "AWS":"arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
    },
    "Action": "SNS:Publish",
    "Resource": "${aws_sns_topic.cloudsploit-sns-topic.arn}"
  },
  {
    "Sid": "eventsstatement",
    "Effect": "Allow",
    "Principal": {
      "Service": "events.amazonaws.com"
    },
    "Action": "SNS:Publish",
    "Resource": "${aws_sns_topic.cloudsploit-sns-topic.arn}"
   }
  ]
}
POLICY
}

# Creates the SNS Topic Subscription to the CloudSploit HTTPS Endpoint
resource "aws_sns_topic_subscription" "cloudsploit-sns-subscription" {
  topic_arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
  protocol = "https"
  endpoint = "${var.URLBase}${data.aws_caller_identity.current.account_id}?id=${var.Externalid}"
  endpoint_auto_confirms = true
}

# Creates the CloudWatch event rules and and sets the targets to the SNS Topic.
resource "aws_cloudwatch_event_rule" "SignInRule" {
  count = "${var.SendSignInEvents == true ? 1 : 0}"
  name = "cloudsploit-console-signin"
  description = "Send console:Signin Events to CloudSploit"

  event_pattern = <<PATTERN
  {
    "detail-type": [
      "AWS Console Sign In via CloudTrail"
    ]
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "SignInRule" {
  rule = "${aws_cloudwatch_event_rule.SignInRule.name}"
  target_id = "cloudsploit-sns"
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
}

resource "aws_cloudwatch_event_rule" "ACMRule" {
  count = "${var.SendACMEvents == true ? 1 :0}"
  name = "cloudsploit-acm"
  description = "Send acm:* Events to CloudSploit"

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.acm"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "acm.amazonaws.com"
      ]
    }
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "ACMRule" {
  rule = "${aws_cloudwatch_event_rule.ACMRule.name}"
  target_id = "cloudsploit-sns"
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
}

resource "aws_cloudwatch_event_rule" "CloudTrailRule" {
  count = "${var.SendCloudTrailEvents == true ? 1 : 0}"
  name = "cloudsploit-cloudtrail"
  description = "Send cloudtrail:* Events to CloudSploit"

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.cloudtrail"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "cloudtrail.amazonaws.com"
      ],
      "eventName": [
        "CreateTrail",
        "DeleteTrail",
        "RemoveTags",
        "StartLogging",
        "StopLogging",
        "UpdateTrail"
      ]
    }
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "CloudTrailRule" {
  rule = "${aws_cloudwatch_event_rule.CloudTrailRule.name}"
  target_id = "cloudsploit-sns"
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
}

resource "aws_cloudwatch_event_rule" "ConfigRule" {
  count = "${var.SendConfigEvents == true ? 1 : 0}"
  name = "cloudsploit-config"
  description = "Send config:* Events to CloudSploit"

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.config"
    ],
    "detail-type" : [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "config.amazonaws.com"
      ],
      "eventName": [
        "DeleteConfigRule",
        "DeleteDeliveryChannel",
        "DeleteEvaluationResults",
        "StopConfigurationRecorder"
      ]
    }
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "ConfigRule" {
  rule = "${aws_cloudwatch_event_rule.ConfigRule.name}"
  target_id = "cloudsploit-sns"
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
}

resource "aws_cloudwatch_event_rule" "EC2Rule" {
  count = "${var.SendEC2Events == true ? 1 : 0}"
  name = "cloudsploit-ec2"
  description = "Send ec2:* Events to CloudSploit"

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.ec2"
    ],
    "detail-type": [
      "AWS API Call via Cloudtrail"
    ],
    "detail": {
      "eventSource": [
        "ec2.amazonaws.com"
      ],
      "eventName": [
        "AcceptVpcPeeringConnection",
				"AuthorizeSecurityGroupEgress",
				"AuthorizeSecurityGroupIngress",
				"CreateNetworkAclEntry",
				"CreateVpcPeeringConnection",
				"CreateRoute",
				"CreateSecurityGroup",
				"DeleteFlowLogs",
				"DeleteSecurityGroup",
				"ImportKeyPair",
				"RevokeSecurityGroupEgress",
				"RevokeSecurityGroupIngress",
				"CreateVpnConnection",
				"CreateVpnConnectionRoute",
				"CreateVpnGateway",
				"DeleteNetworkAclEntry",
				"ReplaceNetworkAclEntry"
      ]
    }
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "EC2Rule" {
  rule = "${aws_cloudwatch_event_rule.EC2Rule.name}"
  target_id = "cloudsploit-sns"
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
}

resource "aws_cloudwatch_event_rule" "IAMRule" {
  count = "${var.SendIAMEvents == true ? 1 : 0}"
  name = "cloudsploit-iam"
  description = "Send iam:* Events to CloudSploit"

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.iam"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "iam.amazonaws.com"
      ]
    }
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "IAMRule" {
  rule = "${aws_cloudwatch_event_rule.IAMRule.name}"
  target_id = "cloudsploit-sns"
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
}

resource "aws_cloudwatch_event_rule" "KMSRule" {
  count = "${var.SendKMSEvents == true ? 1 : 0}"
  name = "cloudsploit-kms"
  description = "Send kms:* Events to CloudSploit"

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.kms"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "kms.amazonaws.com"
      ],
      "eventName": [
        "DisableKeyRotation",
        "PutKeyPolicy"
      ]
    }
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "KMSRule" {
  rule = "${aws_cloudwatch_event_rule.KMSRule.name}"
  target_id = "cloudsploit-sns"
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
}

resource "aws_cloudwatch_event_rule" "LogsRule" {
  count = "${var.SendLogsEvents == true ? 1 : 0}"
  name = "cloudsploit-logs"
  description = "Send logs:* Events to CloudSploit"

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.logs"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "logs.amazonaws.com"
      ],
      "eventName": [
        "DeleteLogGroup",
        "DeleteLogStream",
        "PutRetentionPolicy",
        "DeleteRetentionPolicy"
      ]
    }
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "LogsRule" {
  rule = "${aws_cloudwatch_event_rule.LogsRule.name}"
  target_id = "cloudsploit-sns"
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
}

resource "aws_cloudwatch_event_rule" "RDSRule" {
  count = "${var.SendRDSEvents == true ? 1 : 0}"
  name = "cloudsploit-rds"
  description = "Send rds:* Events to CloudSploit"

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.rds"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "rds.amazonaws.com"
      ],
      "eventName": [
        "AuthorizeDBSecurityGroupIngress",
				"RevokeDBSecurityGroupIngress",
				"RestoreDBInstanceToPointInTime",
				"RestoreDBInstanceFromDBSnapshot",
				"RestoreDBClusterFromSnapshot",
				"RestoreDBClusterToPointInTime",
				"DeleteDBCluster",
				"DeleteDBInstance",
				"DeleteDBSecurityGroup"
      ]
    }
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "RDSRule" {
  rule = "${aws_cloudwatch_event_rule.RDSRule.name}"
  target_id = "cloudsploit-sns"
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
}

resource "aws_cloudwatch_event_rule" "Route53Rule" {
  count = "${var.SendRoute53Events == true ? 1 : 0}"
  name = "cloudsploit-route53"
  description = "Send route53:* Events to CloudSploit"

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.route53"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "route53.amazonaws.com"
      ],
      "eventName": [
        "CreateHostedZone",
        "DeleteHostedZone"
      ]
    }
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "Route53Rule" {
  rule = "${aws_cloudwatch_event_rule.Route53Rule.name}"
  target_id = "cloudsploit-sns"
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
}

resource "aws_cloudwatch_event_rule" "SESRule" {
  count = "${var.SendSESEvents == true ? 1 : 0}"
  name = "cloudsploit-ses"
  description = "Send ses:* Events to CloudSploit"

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.ses"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "ses.amazonaws.com"
      ],
      "eventName": [
        "SetIdentityDkimEnabled",
				"VerifyDomainDkim",
				"VerifyDomainIdentity",
				"VerifyEmailAddress",
				"VerifyEmailIdentity"
      ]
    }
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "SESRule" {
  rule = "${aws_cloudwatch_event_rule.SESRule.name}"
  target_id = "cloudsploit-sns"
  arn = "${aws_sns_topic.cloudsploit-sns-topic.arn}"
}
