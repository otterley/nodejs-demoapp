# Used by `image`, `push` & `deploy` targets, override as required
IMAGE_REG ?= 749049578452.dkr.ecr.us-west-2.amazonaws.com
IMAGE_REPO ?= nodejs-demoapp
IMAGE_TAG ?= latest

# Used by `deploy` target, sets AWS deployment defaults, override as required
AWS_REGION ?= us-west-2
AWS_STACK_NAME ?= demoapps
AWS_APP_NAME ?= nodejs-demoapp

# Used by `test-api` target
TEST_HOST ?= localhost:3000

# Don't change
SRC_DIR := src

.PHONY: help lint lint-fix image push run deploy undeploy clean test test-api test-report .EXPORT_ALL_VARIABLES
.DEFAULT_GOAL := help

help: ## 💬 This help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

lint: $(SRC_DIR)/node_modules ## 🔎 Lint & format, will not fix but sets exit code on error 
	cd $(SRC_DIR); npm run lint

lint-fix: $(SRC_DIR)/node_modules ## 📜 Lint & format, will try to fix errors and modify code
	cd $(SRC_DIR); npm run lint-fix

image: ## 🔨 Build container image from Dockerfile 
	docker build . --file build/Dockerfile \
	--tag $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

push: ## 📤 Push container image to registry 
	docker push $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

run: $(SRC_DIR)/node_modules ## 🏃 Run locally using Node.js
	cd $(SRC_DIR); npm run watch
	
deploy: ## 🚀 Deploy to AWS App Runner
	@echo "### 🚫 Not implemented yet"
	@false
#   @echo "### 🚀 App deployed & available here: ... "

undeploy: ## 💀 Remove from AWS 
	@echo "### 🚫 Not implemented yet"
	@false
#   @echo "### WARNING! Going to delete $(AWS_STACK_NAME) 😲"

test: $(SRC_DIR)/node_modules ## 🎯 Unit tests with Mocha
	cd $(SRC_DIR); npm run test

test-report: $(SRC_DIR)/node_modules ## 🤡 Unit tests with Mocha & mochawesome report 
	rm -rf $(SRC_DIR)/test-results.*
	cd $(SRC_DIR); npm run test-report

test-api: $(SRC_DIR)/node_modules .EXPORT_ALL_VARIABLES ## 🚦 Run integration API tests, server must be running 
	cd $(SRC_DIR); npm run test-postman

clean: ## 🧹 Clean up project
	rm -rf $(SRC_DIR)/node_modules
	rm -rf $(SRC_DIR)/*.xml

# ============================================================================

$(SRC_DIR)/node_modules: $(SRC_DIR)/package.json
	cd $(SRC_DIR); npm install --silent
	touch -m $(SRC_DIR)/node_modules

$(SRC_DIR)/package.json: 
	@echo "package.json was modified"
