provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  profile = var.aws_profile
  token = var.session_token
}