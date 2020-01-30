data "aws_iam_policy_document" "lambda_role_default_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default-role" {
  name               = "playground-lambda-default-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_default_policy.json

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_policy" "lambda_default_logs_policy" {
  name = "playground-lambda-default-logs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "sqs:SendMessage"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "cloudwatch:PutMetricData",
        "cloudwatch:SetAlarmState"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_default_logs_policy" {
  name       = "playground-lambda-default-logs-policy"
  roles      = [aws_iam_role.default-role.name]
  policy_arn = aws_iam_policy.lambda_default_logs_policy.arn
}
