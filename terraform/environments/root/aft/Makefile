# AWS account
ENV ?= shared

# AWS Account ID (shared)
ACCOUNT_ID ?= 195741991018

# AWS region
REGION ?= us-east-1

# AWS profile
PROFILE ?= cropdroid-mgmt

# CodeCommit repository branch (repo-init)
BRANCH ?= master

# Tag to use when committing terraform envs / modules
TAG ?= v0.0.1a

# Commit message to use when pushing envs / modules
COMMIT_MESSAGE ?= initial commit

# Terraform environment or shared module
MODULE ?= default

# Used by publish-module target naming convention
MODULE_PREFIX ?= tf-module-

# Git staging directory
GITDIR ?= /tmp/codecommit/$(PROFILE)

.PHONY: bootstrap

bootstrap:
	cd bootstrap && ./bootstrap.sh "${PROFILE}" "${REGION}"

bootstrap-destroy:
	-cd bootstrap && \
	terraform destroy -var "env=${ENV}" -var "profile=${PROFILE}" -var "region=${REGION}" --auto-approve && \
	rm -rf terraform* .terraform* backend.tf

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
	for f in $(shell pwd)/modules/*; do \
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
	for f in $(shell pwd)/environments/*; do \
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

publish-module:
	MOD=$(MODULE_PREFIX)$(MODULE) ; \
	TMPDIR=/tmp/$$MOD ; \
	MODDIR=$(shell pwd)/modules/$(MODULE) ; \
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
