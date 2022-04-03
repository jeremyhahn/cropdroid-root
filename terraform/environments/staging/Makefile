# AWS account
ENV 	  ?= staging

# AWS region
REGION  ?= us-east-1

# AWS profile
PROFILE ?= cropdroid-$(ENV)

.PHONY: bootstrap init autodeploy deploy redeploy clean destroy

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

git-config:
	git config --global credential.helper '!aws --profile $(PROFILE) codecommit credential-helper $$@'
	git config --global credential.useHttpPath true
