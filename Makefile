run-local:
	docker-compose up

### COMMONS ###
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