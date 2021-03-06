# ping is triggered by the initial SQS message
resource "aws_lambda_function" "ping" {
  function_name = var.ping_lambda_name
  handler = "main"
  role = aws_iam_role.default-role.arn
  runtime = "go1.x"
  filename = "dummy.zip"
  description = "a simple lambda function"
  reserved_concurrent_executions = 20
  timeout = 10
  memory_size = 128

  lifecycle {
    ignore_changes = [environment, function_name, filename, runtime, memory_size, timeout]
  }

  tags = {
    Name = var.ping_lambda_name
    Author = var.whoami
    Provisioner = "terraform"
  }
}

# give the ping queue permission to trigger the ping lambda
resource "aws_lambda_permission" "sqs_trigger_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ping.function_name
  principal = "sqs.amazonaws.com"
  source_arn = aws_sqs_queue.ping_queue.arn
}

# map the event source from the ping queue to the ping lambda
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.ping_queue.arn
  function_name = aws_lambda_function.ping.function_name
  batch_size = 1
}

# slack_forwarder is triggered by the deadletter queue
resource "aws_lambda_function" "sns_slack_forwarder" {
  function_name = "sns_slack_forwarder"
  handler = "main"
  role = aws_iam_role.default-role.arn
  runtime = "go1.x"
  filename = "dummy.zip"
  description = "a lambda function that forwards SNS messages to a slack channel"
  reserved_concurrent_executions = 20
  timeout = 10
  memory_size = 128
  environment {
    variables = {
      PING_ALARM_ARN = aws_sns_topic.ping_deadletter_alarm_topic.arn
      PING_ALARM_SLACK_HOOK = var.ping_alarm_slack_hook
    }
  }

  lifecycle {
    ignore_changes = [environment, function_name, filename, runtime, memory_size, timeout]
  }

  tags = {
    Name = "forwarder"
    Author = var.whoami
    Provisioner = "terraform"
  }
}
// if you want to allow the deadletter queue to trigger the forwarder directly, you can use this
//resource "aws_lambda_permission" "sqs_deadletter_trigger_permission" {
//  action = "lambda:InvokeFunction"
//  function_name = aws_lambda_function.slack_forwarder.function_name
//  principal = "sqs.amazonaws.com"
//  source_arn = aws_sqs_queue.ping_queue_deadletter.arn
//}
//
//resource "aws_lambda_event_source_mapping" "sqs_deadletter_trigger" {
//  event_source_arn = aws_sqs_queue.ping_queue_deadletter.arn
//  function_name = aws_lambda_function.slack_forwarder.function_name
//  batch_size = 1
//}

resource "aws_lambda_permission" "forwarder_sns_trigger_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_slack_forwarder.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.ping_deadletter_alarm_topic.arn
}
