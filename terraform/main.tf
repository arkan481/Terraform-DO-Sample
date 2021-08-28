terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a droplet for the app
resource "digitalocean_droplet" "main-droplet" {
  image  = var.droplet_image
  name   = "${var.app_name}-${terraform.workspace}"
  region = var.region
  size   = var.droplet_size
  tags   = [digitalocean_tag.environment-tag.id, digitalocean_tag.terraform.id]

  provisioner "local-exec" {
    command = "echo 'MAIN_DROPLET_PUBLIC_IP=${self.ipv4_address}' >> ./environments/${terraform.workspace}/resource_assets.txt"
  }
}

# Create a mongodb database
resource "digitalocean_database_cluster" "mongo-db" {
  name       = "${var.app_name}-${terraform.workspace}-cluster"
  engine     = "mongodb"
  version    = var.mongodb_version
  size       = var.mongodb_size
  region     = var.region
  node_count = var.mongodb_node_count
  tags   = [digitalocean_tag.environment-tag.id, digitalocean_tag.terraform.id]

  provisioner "local-exec" {
    command = "echo 'MONGO_DB_HOST=${self.host}' >> ./environments/${terraform.workspace}/resource_assets.txt"
  }
}

# Create an environment tag
resource "digitalocean_tag" "environment-tag" {
  name = "${terraform.workspace}"
}

# Create a 'managed by terraform' tag
resource "digitalocean_tag" "terraform" {
  name = "Terraform"
}

# Creating Digital Ocean Project
resource "digitalocean_project" "my-app" {
  name        = "${var.app_name}-${terraform.workspace}"
  description = var.project_desc
  environment = var.environment
  resources   = [digitalocean_droplet.main-droplet.urn, digitalocean_database_cluster.mongo-db.urn]
}