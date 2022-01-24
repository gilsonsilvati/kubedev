# Configure the Terraform Settings
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# ADD Variables
variable "do_token" {
    type = string
    description = "Token to Connection in Digital Ocean"
}

variable "name_cluster" {
    type = string
    description = "Name of Cluster"
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a web server
resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = var.name_cluster
  region = "nyc1"
  version = "1.21.5-do.0"

  node_pool {
    name       = "default"
    size       = "s-4vcpu-8gb"
    node_count = 3
  }
}

# Create a new node_pool
resource "digitalocean_kubernetes_node_pool" "node_critical" {
  cluster_id = digitalocean_kubernetes_cluster.k8s.id

  name       = "critical-pool"
  size       = "s-2vcpu-4gb"
  node_count = 2
}

# Determining exit
output "k8s_endpoint" {
    value = digitalocean_kubernetes_cluster.k8s.endpoint
}

resource "local_file" "k8s_config" {
    content = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
    filename = "kube_config.yaml"
}
