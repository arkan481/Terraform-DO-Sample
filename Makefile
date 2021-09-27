run-local:
	docker-compose up

### COMMON ###

check-env:
ifndef ENV
		$(error Please set ENV=[staging|production])
endif

create-ssh-key: check-env
	cd terraform/environments/$(ENV) && \
		mkdir .ssh && \
			cd .ssh && \
				ssh-keygen -f id_rsa -t rsa -N ""

remove-ssh-key:  check-env
	cd terraform/environments/$(ENV) && \
		rm -R .ssh

### DOCTL OPERATIONS ###

DROPLET_NAME=my-app-$(ENV)

ssh: check-env
	doctl compute ssh $(DROPLET_NAME) \
		--ssh-key-path=./terraform/environments/$(ENV)/.ssh/id_rsa

ssh-cmd: check-env
	@doctl compute ssh $(DROPLET_NAME) \
		--ssh-key-path=./terraform/environments/$(ENV)/.ssh/id_rsa \
		--ssh-command="$(CMD)"

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
ifeq ($(TF_ACTION), apply)
	$(MAKE) create-ssh-key
endif
	@cd terraform && \
		terraform workspace select $(ENV) && \
		terraform $(TF_ACTION) \
		-var-file="./environments/common.tfvars" \
		-var-file="./environments/$(ENV)/config.tfvars"
ifeq ($(TF_ACTION), destroy)
	rm ./terraform/environments/$(ENV)/resource_assets.json
	$(MAKE) remove-ssh-key
else ifeq ($(TF_ACTION), apply) 
	$(MAKE) terraform-json-output
endif

## DOCKER BUILD AND PUSH OPERATIONS

# GITHUB_REF is an environment variable in the source computer of GitHub Actions, the values is like this:
# refs/head/master OR refs/tags/x.x.x.x
GITHUB_REF?=latest
# since we only trigger GitHub actions by a tag push, we call subst function to retrieves only the tag, removing the refs/other-unnecessary-string/
LOCAL_TAG=express-auth:$(subst refs/tags/,,$(GITHUB_REF))
REMOTE_TAG=arkan481/$(LOCAL_TAG)

build:
	docker build -t $(LOCAL_TAG) --platform linux/amd64 .

push:
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)

CONTAINER_NAME=myapp-api
deploy: check-env
	@$(MAKE) ssh-cmd CMD='docker login --username $(DOCKER_USERNAME) --password $(DOCKER_PASSWORD)'
	@echo "Pulling the new Docker image..."
	$(MAKE) ssh-cmd CMD='docker pull $(REMOTE_TAG)'
	@echo "removing the old container..."
	-$(MAKE) ssh-cmd CMD='docker container stop $(CONTAINER_NAME)'
	-$(MAKE) ssh-cmd CMD='docker container rm $(CONTAINER_NAME)'
	@echo "starting the new container..."
	@$(MAKE) ssh-cmd CMD='\
						docker run -d --name=$(CONTAINER_NAME) \
						--restart=unless-stopped \
						-p 80:5000 \
						-e NODE_ENV=production \
						-e PORT=5000 \
						-e MONGO_URI_PRODUCTION="mongodb+srv://$(MONGODB_USER):$(MONGODB_PASSWORD)@$(MONGODB_HOST)" \
						-e GOOGLE_CLIENT_ID_WEBAPP=$(GOOGLE_CLIENT_ID) \
						-e GOOGLE_CLIENT_SECRET=$(GOOGLE_CLIENT_SECRET) \
						-e FILE_UPLOAD_PATH=./public/uploads \
						-e MAX_FILE_UPLOAD=300000 \
						-e JWT_SECRET=$(JWT_SECRET) \
						-e JWT_EXPIRE=$(JWT_EXPIRE) \
						-e JWT_COOKIE_EXPIRE=$(JWT_COOKIE_EXPIRE) \
						-e MONGO_CA_CERT_PATH=config/ca-certificate-$(ENV).crt \
						$(REMOTE_TAG)'

## ANSIBLE OPERATIONS
deploy-ansible: check-env
	@ansible-playbook \
	-i ./ansible/$(ENV)/droplet-host.ini \
	-e NODE_ENV=production \
	-e PORT=5000 \
	-e MONGO_URI_PRODUCTION="mongodb+srv://$(MONGODB_USER):$(MONGODB_PASSWORD)@$(MONGODB_HOST)" \
	-e GOOGLE_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
	-e GOOGLE_CLIENT_SECRET=$(GOOGLE_CLIENT_SECRET) \
	-e FILE_UPLOAD_PATH=./public/uploads \
	-e MAX_FILE_UPLOAD=300000 \
	-e JWT_SECRET=$(JWT_SECRET) \
	-e JWT_EXPIRE=$(JWT_EXPIRE) \
	-e JWT_COOKIE_EXPIRE=$(JWT_COOKIE_EXPIRE) \
	-e MONGO_CA_CERT_PATH=config/ca-certificate-$(ENV).crt \
	-e DOCKER_USERNAME=$(DOCKER_USERNAME) \
	-e DOCKER_PASSWORD=$(DOCKER_PASSWORD) \
	-e DOCKER_EMAIL=$(DOCKER_EMAIL) \
	-e CONTAINER_NAME=$(CONTAINER_NAME) \
	-e REMOTE_TAG=$(REMOTE_TAG) \
	--private-key ./terraform/environments/$(ENV)/.ssh/id_rsa \
	-vvv \
	--timeout 120 \
	./ansible/site.yml