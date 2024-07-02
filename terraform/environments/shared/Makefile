# AWS account
ENV 	  ?= shared

# AWS region
REGION  ?= us-east-1

# AWS profile
PROFILE ?= cropdroid-$(ENV)

# The name of the pipeline to execute
PIPELINE ?= default

# How often to poll pipeline status change
INTERVAL ?= 10

# Codepipeline stage index
STAGE    ?= 2

# CodeCommit repository branch (repo-init)
BRANCH   ?= master

# Tag to use when committing terraform envs / modules
TAG      ?= v0.0.1a

# Commit message to use when pushing envs / modules
COMMIT_MESSAGE ?= initial commit

# Terraform environment or shared module
MODULE ?= default

# Used by publish-module target naming convention
MODULE_PREFIX ?= tf-module-

# Git staging directory
GITDIR ?= /tmp/codecommit/$(PROFILE)

# Docker registry
REGISTRY ?= $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com

# AWS Secrets Manager ID for onelink SVN user
ONELINK_SVN_SECRET_ID ?= /onelink/svn

# S3 artifact bucket
ARTIFACT_BUCKET ?= newlink-artifacts-shared

# Amplify / Bitbucket oauth integration
BITBUCKET_OAUTH_KEY_PARAMETER    ?= /amplify/bitbucket_oauth_key
BITBUCKET_OAUTH_SECRET_PARAMETER ?= /amplify/bitbucket_oauth_secret

.PHONY: bootstrap init autodeploy deploy redeploy clean destroy aft

bootstrap:
	cd bootstrap && ./bootstrap.sh "${PROFILE}" "${REGION}"

# bootstrap-destroy:
# 	-cd bootstrap && terraform destroy
# 	rm -rf bootstrap/terraform* bootstrap/.terraform* bootstrap/backend.tf

init:
	cd $(MODULE) && terraform init \
		-backend-config="profile=${PROFILE}" \
		-backend-config="acl=bucket-owner-full-control"

autodeploy:
	cd $(MODULE) && terraform apply -var "env=${ENV}" -var "profile=${PROFILE}" -var "region=${REGION}" --auto-approve

aft:
	# Passing AWS_PROFILE here so ct_management provider can authenticate
	# https://github.com/jeremyhahn/terraform-aws-control_tower_account_factory/blob/main/providers.tf#L7
	AWS_PROFILE=$(PROFILE) \
	MODULE=aft \
	$(MAKE) deploy

deploy:
	cd $(MODULE) && terraform apply -var "env=${ENV}" -var "profile=${PROFILE}" -var "region=${REGION}"

redeploy:
	$(MAKE) clean
	$(MAKE) init
	$(MAKE) deploy

clean:
	rm -rf $(MODULE)/.terraform*

destroy:
	cd $(MODULE) && terraform destroy -var "env=${ENV}" -var "profile=${PROFILE}" -var "region=${REGION}"

######################3


clone-all:
	mkdir -p $(GITDIR)/repositories
	cd $(GITDIR)/repositories && aws codecommit list-repositories \
		--query "repositories[*].[repositoryName]" \
		--output text \
		--profile $(PROFILE) \
		--region $(REGION) | xargs -L1 -I % git clone codecommit://$(PROFILE)@%

tf-modules:
	-rm -rf $(GITDIR)/tf-modules/tf-module-*
	-mkdir -p $(GITDIR)/tf-modules/
	for f in $(shell pwd)/../../modules/*; do \
		echo "Initializing module: $$f" ; \
		MOD=`basename $$f` ; \
		TMPDIR=$(GITDIR)/tf-modules/tf-module-$$MOD ; \
		git clone --depth=1 codecommit://$(PROFILE)@tf-module-$$MOD $$TMPDIR || true ; \
		cp -R $$f/* $$TMPDIR/ ; \
		cd $$TMPDIR ; \
		git add -A ; \
		git commit -m "$\${COMMIT_MESSAGE}" ; \
		git push origin $(BRANCH) ; \
		git tag -f $(TAG) ; \
		git push -f origin $(TAG)
		echo "\n" ; \
	done

tf-envs:
	-rm -rf $(GITDIR)/tf-envs/tf-env-*
	-mkdir -p $(GITDIR)/tf-envs/
	for f in $(shell pwd)/../*; do \
		echo "Initializing environment: $$f" ; \
		TFENV=`basename $$f` ; \
		TMPDIR=$(GITDIR)/tf-envs/tf-env-$$TFENV ; \
		git clone --depth=1 codecommit://$(PROFILE)@tf-env-$$TFENV $$TMPDIR || true ; \
		cp -R $$f/* $$TMPDIR/ ; \
		cd $$TMPDIR ; \
		echo ".terraform*" > .gitignore ; \
		git add -A ; \
		git commit -m "$\${COMMIT_MESSAGE}" ; \
		git push origin $(BRANCH) ; \
		git tag -f $(TAG) ; \
		git push -f origin $(TAG)
		echo "\n" ; \
	done

tf-modules-oldlink:
	-rm -rf $(GITDIR)/oldlink/
	-mkdir -p $(GITDIR)/oldlink/
	for f in $(shell pwd)/../../modules/oldlink-cluster*; do \
		echo "Initializing oldlink module: $$f" ; \
		MOD=`basename $$f` ; \
		TMPDIR=$(GITDIR)/oldlink/$$MOD ; \
		git clone --depth=1 codecommit://$(PROFILE)@tf-module-$$MOD $$TMPDIR || true ; \
		cp -R $$f/* $$TMPDIR/ ; \
		cd $$TMPDIR ; \
		echo ".terraform*" > .gitignore ; \
		git add -A ; \
		git commit -m "$\${COMMIT_MESSAGE}" ; \
		git push origin $(BRANCH) ; \
		git tag -f $(TAG) ; \
		git push -f origin $(TAG) ; \
		echo "\n" ; \
	done

publish-module:
	MOD=$(MODULE_PREFIX)$(MODULE) ; \
	TMPDIR=/tmp/$$MOD ; \
	MODDIR=$(shell pwd)/../../modules/$(MODULE) ; \
	cd /tmp && rm -rf $$MOD && git clone --depth=1 codecommit://$(PROFILE)@$$MOD ; \
	cd $$MOD ; \
	terraform fmt -recursive ; \
	cp -R $$MODDIR/* $$TMPDIR/ ; \
	git add -A ; \
	git commit -m "$\${COMMIT_MESSAGE}" ; \
	git push origin $(BRANCH) ; \
	git tag -f $(TAG) ; \
	git push -f origin $(TAG)

publish-lambda:
	MODULE_PREFIX= $(MAKE) publish-module

ecr-login:
	aws ecr get-login-password --region $(REGION) --profile $(PROFILE) | docker login --username AWS --password-stdin $(REGISTRY)

git-config:
	git config --global credential.helper '!aws --profile $(PROFILE) codecommit credential-helper $$@'
	git config --global credential.useHttpPath true
