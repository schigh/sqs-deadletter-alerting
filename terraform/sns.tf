resource "aws_sns_topic" "ping_deadletter_alarm_topic" {
  name = "${var.ping_queue_name}-deadletter-alarm-topic"
  display_name = "Deadletter alarm SNS topic"
  tags = {
    Name = "${var.ping_queue_name}-deadletter-alarm-topic"
    Author = var.whoami
    Provisioner = "terraform"
  }
}

data "aws_iam_policy_document" "sns_policy" {
  policy_id = "sns_policy_ping_deadletter_topic_allow"
  statement {
    sid = "sns_stmt_ping_deadletter_topic_allow"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    condition {
      test = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [var.aws_acct_num]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.ping_deadletter_alarm_topic.arn
    ]
  }
}

resource "aws_sns_topic_subscription" "slack" {
  endpoint = aws_lambda_function.forwarder.arn
  protocol = "lambda"
  topic_arn = aws_sns_topic.ping_deadletter_alarm_topic.arn
}
