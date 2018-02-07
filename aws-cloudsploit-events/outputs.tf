// The ARN of the SNS endpoint to give to CloudSploit.
output "SNSTopicARN" {
  value = ["${aws_sns_topic.cloudsploit-sns-topic.arn}"]
}
