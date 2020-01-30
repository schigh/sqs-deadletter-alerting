resource "aws_sqs_queue" "ping_queue_deadletter" {
  name = "${var.ping_queue_name}-deadletter"
  lifecycle {
    ignore_changes  = [name]
  }

  tags = {
    Name = "${var.ping_queue_name}-deadletter"
    Author = var.whoami
    Provisioner = "terraform"
  }
}

resource "aws_sqs_queue" "ping_queue" {
  name = var.ping_queue_name
  max_message_size = 2048
  visibility_timeout_seconds = 30
  message_retention_seconds = 86400
  lifecycle {
    ignore_changes  = [name]
  }

  tags = {
    Name = var.ping_queue_name
    Author = var.whoami
    Provisioner = "terraform"
  }

  policy = <<EOF
{
  "Id": "Policy1580251055421",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1580251048122",
      "Action": "sqs:*",
      "Effect": "Allow",
      "Resource": "arn:aws:sqs:${var.aws_region}:${var.aws_acct_num}:${var.ping_queue_name}",
      "Principal": "*"
    }
  ]
}
EOF

  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${aws_sqs_queue.ping_queue_deadletter.arn}",
  "maxReceiveCount": 5
}
EOF
}
