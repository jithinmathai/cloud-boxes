terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

variable "hcloud_token" {
  sensitive = true
}

variable "firewall_source_ip" {
  default = "0.0.0.0"
}

variable "server_name" {
  description = "Name of the server"
  type        = string
  default     = "control"
}

variable "server_image" {
  description = "OS image to use (e.g., fedora-40, ubuntu-22.04)"
  type        = string
  default     = "fedora-40"
}

variable "server_location" {
  description = "Hetzner Cloud location (e.g., nbg1, fsn1, hel1)"
  type        = string
  default     = "nbg1"
}

variable "server_type" {
  description = "Server type/size (e.g., cx22, cx32, cpx11)"
  type        = string
  default     = "ccx23"
}

variable "ssh_keys" {
  description = "List of SSH key names to add to the server"
  type        = list(string)
  default     = ["key1"]
}

variable "keep_disk" {
  description = "Keep the disk when the server is deleted"
  type        = bool
  default     = true
}

variable "firewall_name" {
  description = "Name of the firewall"
  type        = string
  default     = "common-firewall"
}

variable "ssh_port" {
  description = "Port to expose for SSH access"
  type        = string
  default     = "22"
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_firewall" "common-firewall" {
  name = "common-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = var.ssh_port
    source_ips = [
      "${var.firewall_source_ip}/32"
    ]
  }

  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "${var.firewall_source_ip}/32"
    ]
  }
}

resource "hcloud_server" "control" {
  name        = var.server_name
  image       = var.server_image
  location    = var.server_location
  server_type = var.server_type
  keep_disk   = var.keep_disk
  ssh_keys    = var.ssh_keys
  firewall_ids = [hcloud_firewall.common-firewall.id]
}

output "control_public_ip4" {
  value = "${hcloud_server.control.ipv4_address}"
}
