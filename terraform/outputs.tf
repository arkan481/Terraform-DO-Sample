output "droplet-public-ip" {
  value = digitalocean_droplet.main-droplet.ipv4_address
}

output "mongodb-host" {
  value = digitalocean_database_cluster.mongo-db.host
  sensitive = true
}

output "mongodb-user" {
  value = var.mongodb_user
  sensitive = true
}

output "mongodb-password" {
  value = digitalocean_database_user.mongodb-user.password
  sensitive = true
}

output "mongodb-admin-user" {
  value = digitalocean_database_cluster.mongo-db.user
  sensitive = true
}

output "mongodb-admin-password" {
  value = digitalocean_database_cluster.mongo-db.password
  sensitive = true
}