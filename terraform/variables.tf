#######################################
# COMMON
#######################################
variable "do_token" {
  type = string
}

variable "region" {
  type = string
}

variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_desc" {
  type = string
}

#######################################
# DROPLET
#######################################
variable "droplet_image" {
  type = string
}

variable "droplet_size" {
  type = string
}

#######################################
# MONGODB
#######################################
variable "mongodb_size" {
  type = string
}

variable "mongodb_version" {
  type = string
}

variable "mongodb_node_count" {
  type = number
}

variable "mongodb_user" {
  type = string
}