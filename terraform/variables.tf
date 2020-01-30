variable "aws_access_key" {
  description = "aws access key"
}

variable "aws_secret_key" {
  description = "aws secret key"
}

variable "aws_profile" {
  description = "the named profile to use"
}

variable "session_token" {
  description = "MFA session token"
}

variable "aws_region" {
  description = "aws region"
}

variable "aws_acct_num" {
  description = "aws account number"
}

variable "ping_lambda_name" {
  default = "ping-lambda"
}

variable "ping_queue_name" {
  default = "ping-queue"
}

variable "whoami" {
  description = "your name"
}

variable "ping_alarm_slack_hook" {
  description = "webhook endpoint for ping alarm"
}
