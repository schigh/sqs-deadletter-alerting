.DEFAULT_GOAL := help

_YELLOW=\033[0;33m
_NC=\033[0m

PKG_DIRS := $(shell go list -f '{{.Dir}}' ./...)
PROJROOT := $(shell pwd)
OUTPUT_DIR := $(PROJROOT)/build

.PHONY: require_env-%
require_env-%:
	@ if [ "${${*}}" = "" ]; then \
  		echo "Environment variable $* not set"; \
  		exit 1; \
  	  fi

.PHONY: help # generic commands
help: ## prints this help
	@grep -hE '^[\.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "${_YELLOW}%-16s${_NC} %s\n", $$1, $$2}'

.PHONY: lambda
lambda: require_env-WORKER_ARN require_env-AWS_REGION require_env-AWS_PROFILE ## build and push the lambda function
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a -installsuffix cgo -o main main.go
	@zip -rX main.zip main
	@aws lambda update-function-code --function-name "${WORKER_ARN}" --zip-file "fileb://${PROJROOT}/main.zip" --publish --region "${AWS_REGION}" --profile "${AWS_PROFILE}"
	@rm -f $(PROJROOT)/main
	@rm -f $(PROJROOT)/main.zip

.PHONY: forwarder
forwarder: require_env-WORKER_ARN require_env-AWS_REGION require_env-AWS_PROFILE ## build and push the forwarder function
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -tags forwarder -a -installsuffix cgo -o main forwarder.go
	@zip -rX main.zip main
	@aws lambda update-function-code --function-name "${WORKER_ARN}" --zip-file "fileb://${PROJROOT}/main.zip" --publish --region "${AWS_REGION}" --profile "${AWS_PROFILE}"
	@rm -f $(PROJROOT)/main
	@rm -f $(PROJROOT)/main.zip

.PHONY: token
token: require_env-AWS_ROLE_ARN require_env-AWS_PROFILE require_env-AWS_SESS_NAME ## refresh aws token
	@ bash ./get_token.sh
