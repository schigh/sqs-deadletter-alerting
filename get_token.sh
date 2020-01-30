#!/usr/bin/env bash

# this uses the aws cli to generate a session token and put in a tfvars file
set -e

AWS_CMD=$(command -v aws 2> /dev/null)
JQ_CMD=$(command -v jq 2> /dev/null)

if [ -z "${AWS_CMD}" ]; then
  echo "aws not found"
  exit 1
fi

if [ -z "${JQ_CMD}" ]; then
  echo "jq not found"
  exit 1
fi

if [ -z "${AWS_ROLE_ARN}" ]; then
  echo "ROLE ARN:"
  read -r AWS_ROLE_ARN
fi

if [ -z "${AWS_PROFILE}" ]; then
  echo "PROFILE NAME:"
  read -r AWS_PROFILE
fi

if [ -z "${AWS_SESS_NAME}" ]; then
  echo "SESSION NAME:"
  read -r AWS_SESS_NAME
fi

aws sts assume-role \
--role-arn "${AWS_ROLE_ARN}" \
--role-session-name "${AWS_SESS_NAME}" \
--profile "${AWS_PROFILE}" \
--duration-seconds 3600 > session_token

ACCESS_KEY=$(jq '.Credentials.AccessKeyId' < session_token)
SECRET_KEY=$(jq '.Credentials.SecretAccessKey' < session_token)
SESS_TOKEN=$(jq '.Credentials.SessionToken' < session_token)

cat << EOF > ./terraform/terraform.tfvars
# generated $(date)
aws_access_key = ${ACCESS_KEY}
aws_secret_key = ${SECRET_KEY}
aws_profile = "${AWS_PROFILE}"
session_token = ${SESS_TOKEN}

EOF

rm -f session_token
