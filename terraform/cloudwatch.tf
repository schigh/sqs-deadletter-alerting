resource "aws_cloudwatch_metric_alarm" "ping_queue_deadletter_alarm" {
  alarm_name = "${var.ping_queue_name}-deadletter-alarm"
  alarm_description = "this alarm is triggered when messages are sent to a deadletter queue"
  comparison_operator = "GreaterThanThreshold"
  namespace = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"
  statistic = "Maximum"
  evaluation_periods = 1
  period = 60
  threshold = 0
  dimensions = {
    QueueName = aws_sqs_queue.ping_queue_deadletter.name
  }
  alarm_actions = [aws_sns_topic.ping_deadletter_alarm_topic.arn]
  tags = {
    Name = "${var.ping_queue_name}-deadletter-alarm"
    Author = var.whoami
    Provisioner = "terraform"
  }
}
