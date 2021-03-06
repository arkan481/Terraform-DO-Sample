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

resource "digitalocean_ssh_key" "my-app-default" {
  name = "MyApp Default"
  public_key = file("./environments/${terraform.workspace}/.ssh/id_rsa.pub")
}

# Create a droplet for the app
resource "digitalocean_droplet" "main-droplet" {
  image  = var.droplet_image
  name   = "${var.app_name}-${terraform.workspace}"
  region = var.region
  size   = var.droplet_size
  ssh_keys = [ digitalocean_ssh_key.my-app-default.fingerprint ]
  tags   = [digitalocean_tag.environment-tag.id, digitalocean_tag.terraform.id]
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
}

# Create a firewall rule to blacklist any connection to MongoDB except for the droplet
resource "digitalocean_database_firewall" "mongodb-firewall" {
  cluster_id = digitalocean_database_cluster.mongo-db.id

  rule {
    type = "droplet"
    value = digitalocean_droplet.main-droplet.id
  }
}

# Create a MongoDB database user that will be used for the droplet connection
resource "digitalocean_database_user" "mongodb-user" {
  cluster_id = digitalocean_database_cluster.mongo-db.id

  name = var.mongodb_user
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