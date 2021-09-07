# Welcome to TerraformDOSample 👋
![Version](https://img.shields.io/badge/version-v1.0.0-blue.svg?cacheSeconds=2592000)
[![Twitter: arkanharyo](https://img.shields.io/twitter/follow/arkanharyo.svg?style=social)](https://twitter.com/arkanharyo)
![Build Push Deploy](https://github.com/arkan481/Terraform-DO-Sample/workflows/Build,%20push%20to%20DockerHub%20and%20deploy%20to%20DigitalOcean%20Droplet/badge.svg)

> CI/CD sample with Github Actions and Terraform to automate infrastructure provisioning and deploying to DigitalOcean cloud infrastructure provider.

## Branching Strategy
![Git Workflow](GitWorkflow.png "Git Workflow")

## Local Setup
Fill in every environment variables in config/config.env file.

Then run:

```zsh
make run-local
```

This will use docker-compose to build the application into a docker image and then run it alongside a Mongo DB container, with the environment sets to `development`.

## The Image
### Requirements
1. Fill in all of the config.env fields.
2. Google authentication client ID and secret.
3. Registered domain for `Authorized redirect URIs` in Google console.
4. For `production` use, you need a DigitalOcean mongodb TLS crt file, download and put it in `config/`, only then you can proceed to build the image for production use.

## Terraform
### The Terraform configuration provisions:
- DigitalOcean Droplet
- DigitalOcean MongoDB Cluster

### Using the Terraform config requires:
1. A DigitalOcean access token

### The Terraform configuration configure these environments:
1. staging
2. production

### 🚀 Spinning up an environment
1. Fill in all of the tfvars file, in the particular environment dir and the common.tfvars file located inside the root of environments dir.
2. Spin up your environment by running:
```zsh
ENV=env-name TF_ACTION=apply make terraform-action
```

### 🌟 Creating a new environment
> 💡 DigitalOcean's project resource can only have 3 environments value, they are: `Development`, `Staging`, and `Production`.
1. Create a new terraform environment directory under /terraform/environments and copy the tfvars file from other environments.
2. Create a new terraform workspace by running:
```zsh
ENV=new-env-name make terraform-create-workspace
```
3. Initiate the new Terraform workspace environment by running:
```zsh
ENV=new-env-name make terraform-init
```
4. Spin up your new environment by running:
```zsh
ENV=new-env-name TF_ACTION=apply make terraform-action
```

### 🧨 Cleaning up an environment
1. Clean up your Terraform resources by runnning:
```zsh
ENV=new-env-name TF_ACTION=destroy make terraform-action
```

### 📜 After spinning up an environment
After spinning up an environment you will get every output that were exported into a json file named `resource_assets.json` that contains necessary credentials for your infrastructure.

## Docker Build and Push
### 📀 Building the new Docker image
1. Make sure to fill in all of the necessary env variable in /config/config.env, or pass this during the `docker run` command.
2. MAKE SURE to put the `mongodb` crt file `BEFORE` building the image for production environment.
3. Finally to build your new Docker image locally, run this command:
```zsh
make build
```

### ☄️ Pushing the new Docker Image
1. Build your Docker image using the steps above.
2. Change the REMOTE_TAG variable in Makefile with your own DockerHub username.
3. Push your Docker image to DockerHub locally by running this command:
```zsh
make push
```

## GitHub Action
### ✒️ Requirements
This GitHub Action config will require these following secrets to be stored in GitHub repo.
1. DOCKERHUB_USERNAME  
Which contains a string of your DockerHub username.
2. DOCKERHUB_TOKEN
Which contains a string of your DockerHub access token.

### 🧙‍♂️ Workflow
`.github/workflows/build-push-deploy.yaml` contains a workflow which deploys to a `staging` environment on pushes to tags with prefix of `v\d+\.\d+\.\d+\-alpha.\d+`, ex: `v1.0.0-alpha.1` and to a `production` environment on pushes of tags of the form `v\d+\.\d+\.\d+`, ex: `v1.0.0`. It also push a Docker image to Docker Hub tagged with the push tag of GitHub tag.

## DOCTL
### 📈 Usage 
This project use DigitalOcean's official CLI tool called DOCTL, the usage of this CLI tools is to:
1. Accessing droplet using SSH depending to the specified environment by running:
```zsh
ENV=<your-own-environment | staging | production> make ssh
```
2. Issuing a command to droplet using SSH depending to the specified environment by running:
```zsh
ENV=<your-own-environment | staging | production> make ssh-cmd CMD="your-command-goes-here"
```
3. Issuing a deployment that triggers docker login, image pull, and image re-run to droplet using SSH with CMD to the specified environment by running:
```zsh
ENV=<your-own-environment | staging | production> make deploy DOCKER_USERNAME=changeme DOCKER_PASSWORD=changeme PORT=5000 MONGODB_USER_<your-own-environment | staging | production>=changeme MONGODB_PASSWORD_<your-own-environment | staging | production>=changeme MONGODB_HOST_<your-own-environment | staging | production>=changeme GOOGLE_CLIENT_ID=changeme GOOGLE_CLIENT_SECRET=changeme JWT_SECRET=changeme JWT_EXPIRE=changeme JWT_COOKIE_EXPIRE=changeme
```
> 💡 You should find most of the value of the environment variables in `terraform/environemnts/<your-own-environment | staging | production>/resource_assets.json`

### Requirements
1. In order to deploy the app you need to download the mongodb tls cert using digital ocean console, and you should format the file name to this: `ca-certificate-<your-own-environment | staging | production>.crt`

## Where to go After This?
- Use secret manager for convenience.
- Use a domain with SSL cert as a part of the deployment.
- Learn to develop a Telegram bot to automate change log notifying system to a group chat.
- `Learn Ansible` for server management tools, because Terraform is used only for provisioning or in other words creating a server, after we've created a server we need to manage it (installing apps, running docker, upgrading, etc.) So wee need to use a configuration management tools such as Ansible.

## To-Do
### Terraform
- [x] Make file for terraform operations.
- [x] Delete resource_assets.json when destroying terraform resources.
- [x] User and password for mongodb DigitalOcean resource.
- [x] Whitelist IP for the droplet's IP only.
- [x] Migrate local-exec provisioner to outputs.
- [x] Check to see wether or not the droplet can connect to mongodb cluster without crt (You can't), workaround is to download the crt file from DO's GUI console, put the crt file into the application itself, so if in the future the crt change, the app / image needs to be built again, see [Is it possible to download the managed database's ca-certificate.crt using the DO API, or similar?](https://www.digitalocean.com/community/questions/is-it-possible-to-download-the-managed-database-s-ca-certificate-crt-using-the-do-api-or-similar).
- [x] Update all sample files.
- [x] Document Terraform operations.

### Docker Build and Push
- [x] Configure Docker private repository.
- [x] Tag the image with Docker private repository url.
- [x] Configure automatic tagging with Git tags.
- [x] Push the built Docker image to DockerHub by using GitHub action.
- [x] Document Build and Push operations.

### Verify Image Working
- [x] Test image locally with both development and production environment.
- [x] Environment variable clean up.
- [x] Document the image requirements.

### DOCTL Deployment (Manual Deployment)
- [x] Create a SSH key resource using Terraform
- [x] Confiture Droplet's SSH key using Terraform.
- [x] Configure Docker login in droplet.
- [x] Deploy the app using `docker run` command.
- [x] Separate crt file for production and staging env.
- [x] Old image and container clean up.
- [x] Documents the requirements of the deployment process.

### GitHub Action Deployment (Automatic Deployment)
- [x] Figure out a way to make a temp dir of .ssh and create id_rsa file in GitHub Action instance under `terraform/environments/some-env/` in order to support the use of `doctl compute ssh` command.
- [x] Store every environment variables in GitHub secret.
- [x] Separate environment variable for staging and production.
- [x] Create a mechanism to detect which environments is currently targeted.
- [x] Fix ENV prefix for `make` deploy script, just remove the environment string.

## References
Here are the list of useful and awesome resources that helped me during the learning process:
- [Traversy Media](https://www.youtube.com/channel/UC29ju8bIPH5as8OGnQzwJyA) - 
[DevOps Crash Course (Docker, Terraform, and Github Actions)](https://www.youtube.com/watch?v=OXE2a8dqIAI&t=2427s)
- [Complete Terraform Course - Beginner to Advanced [2021]](https://www.udemy.com/course/complete-terraform-course-beginner-to-advanced/)
- [DevOps Directive YouTube Channel](https://www.youtube.com/channel/UC4MdpjzjPuop_qWNAvR23JA)

## Author

👤 **Arkan Haryo**

* Twitter: [@arkanharyo](https://twitter.com/arkanharyo)
* Github: [@arkan481](https://github.com/arkan481)
* LinkedIn: [@arkanharyo](https://linkedin.com/in/arkanharyo)

## Show your support

Give a ⭐️ if this project helped you!


***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_