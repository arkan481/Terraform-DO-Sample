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
- [ ] Create DigitalOcean mongodb module.
- [x] Check to see wether or not the droplet can connect to mongodb cluster without crt (You can't), workaround is to download the crt file from DO's GUI console, put the crt file into the application itself, so if in the future the crt change, the app / image needs to be built again, see [Is it possible to download the managed database's ca-certificate.crt using the DO API, or similar?](https://www.digitalocean.com/community/questions/is-it-possible-to-download-the-managed-database-s-ca-certificate-crt-using-the-do-api-or-similar).
- [x] Update all sample files.
- [ ] Document Terraform operations.

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