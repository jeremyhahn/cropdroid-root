LAMBDA_NAME ?= s3-event-notification

REGION ?= us-east-1

PROFILE ?= cropdroid-staging

default: package update

package:
	cd lambda && zip -r ../$(LAMBDA_NAME).zip *

update:
	aws lambda update-function-code \
		--function-name $(LAMBDA_NAME) \
		--zip-file fileb://$(LAMBDA_NAME).zip \
		--region $(REGION) \
		--profile $(PROFILE)
