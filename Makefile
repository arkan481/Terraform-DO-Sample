run-local:
	docker-compose up

### COMMON ###

check-env:
ifndef ENV
		$(error Please set ENV=[staging|production])
endif

### TERRAFORM OPERATIONS ###

terraform-create-workspace: check-env
	cd terraform && \
		terraform workspace new $(ENV)

terraform-init: check-env
	cd terraform && \
		terraform workspace select $(ENV) && \
		terraform init

terraform-json-output: check-env
	@cd terraform && \
		terraform workspace select $(ENV) && \
		echo $$(terraform output -json) > ./environments/$(ENV)/resource_assets.json

TF_ACTION?=plan
terraform-action: check-env
	@cd terraform && \
		terraform workspace select $(ENV) && \
		terraform $(TF_ACTION) \
		-var-file="./environments/common.tfvars" \
		-var-file="./environments/$(ENV)/config.tfvars"
ifeq ($(TF_ACTION), destroy)
	rm ./terraform/environments/$(ENV)/resource_assets.json
else ifeq ($(TF_ACTION), apply) 
	@cd terraform && \
		echo $$(terraform output -json) > ./environments/$(ENV)/resource_assets.json
endif

## DOCKER BUILD AND PUSH OPERATIONS

# GITHUB_REF is an environment variable in the source computer of GitHub Actions, the values is like this:
# refs/head/master OR refs/tags/x.x.x.x
GITHUB_REF?=latest
# since we only trigger GitHub actions by a tag push, we call subst function to retrieves only the tag, removing the refs/other-unnecessary-string/
LOCAL_TAG=express-auth:$(subst refs/tags/,,$(GITHUB_REF))
REMOTE_TAG=arkan481/$(LOCAL_TAG)

build:
	docker build -t $(LOCAL_TAG) .

push:
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)