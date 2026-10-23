variable "instance_name" {
  type        = string
  description = "Name of the compute instance to create"
  default     = "stellaris-instance"
}

variable "image_name" {
  type        = string
  description = "Name of the Glance image to boot from (e.g. RHEL8, Ubuntu 22.04)"
}

variable "flavor_name" {
  type        = string
  description = "Name of the Nova compute flavor (e.g. SSC-4V-8G, m1.small)"
}

variable "volume_size_gb" {
  type        = number
  description = "Size of the root boot volume in GB (required for 0-disk clouds)"
  default     = 20
}

variable "volume_type" {
  type        = string
  description = "Cinder volume type (optional, leave empty for cloud default)"
  default     = ""
}

variable "network_name" {
  type        = string
  description = "Name of the internal private network to create"
  default     = "stellaris-internal-net"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for the internal private subnet"
  default     = "192.168.10.0/24"
}

variable "dns_nameservers" {
  type        = list(string)
  description = "DNS servers for the private subnet"
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "router_name" {
  type        = string
  description = "Name of the Neutron router to create"
  default     = "stellaris-router"
}

variable "external_gateway_network_id" {
  type        = string
  description = "UUID of the external/public network providing internet gateway access"
}

variable "external_floating_ip_pool" {
type        = string
description = "Name of the external network pool to allocate floating IPs from (e.g. external-network)"
}

variable "ssh_public_key" {
  type        = string
  description = "Optional SSH public key content. If empty, OpenStack Nova auto-generates a new 2048-bit keypair"
  default     = ""
}

variable "keypair_name" {
  type        = string
  description = "Name of the keypair to create in OpenStack"
  default     = "stellaris-key"
}

variable "custom_welcome_message" {
  type        = string
  description = "Custom message to print in the instance bash startup script"
  default     = "Provisioned successfully by Stellaris!"
}
