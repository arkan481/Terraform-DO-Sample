# Welcome to TerraformDOSample 👋
![Version](https://img.shields.io/badge/version-v1.0.0-blue.svg?cacheSeconds=2592000)
[![Twitter: arkanharyo](https://img.shields.io/twitter/follow/arkanharyo.svg?style=social)](https://twitter.com/arkanharyo)

> CI/CD sample with Github Actions and Terraform to automate infrastructure provisioning and deploying to DigitalOcean cloud infrastructure provider.

## Branching Strategy
![Git Workflow](GitWorkflow.png "Git Workflow")

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
- [ ] Configure automatic tagging with Git SHA.
- [ ] Document Build and Push operations.

## Local Setup
Fill in every environment variables in config/config.env file.

Then run:

```zsh
make run-local
```

This will use docker-compose to build the application into a docker image and then run it alongside a Mongo DB container, with the environment sets to `development`.

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


## Where to go After This?
`Learn Ansible` for server management tools, because Terraform is used only for provisioning or in other words creating a server, after we've created a server we need to manage it (installing apps, running docker, upgrading, etc.) So wee need to use a configuration management tools such as Ansible.

## Author

👤 **Arkan Haryo**

* Twitter: [@arkanharyo](https://twitter.com/arkanharyo)
* Github: [@arkan481](https://github.com/arkan481)
* LinkedIn: [@arkanharyo](https://linkedin.com/in/arkanharyo)

## Show your support

Give a ⭐️ if this project helped you!


***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_