output "ping_lambda_arn" {
  value = aws_lambda_function.ping.arn
}

output "forwarder_lambda_arn" {
  value = aws_lambda_function.sns_slack_forwarder.arn
}

output "ping_queue_arn" {
  value = aws_sqs_queue.ping_queue.arn
}

output "ping_queue_deadletter_arn" {
  value = aws_sqs_queue.ping_queue_deadletter.arn
}

output "ping_queue_deadletter_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.ping_queue_deadletter_alarm.arn
}

output "ping_queue_deadletter_alarm_topic_arn" {
  value = aws_sns_topic.ping_deadletter_alarm_topic.arn
}
