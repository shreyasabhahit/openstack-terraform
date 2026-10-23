variable "instance_name" {
  type        = string
  description = "Name of the Web instance"
  default     = "prod-web"
}

variable "image_name" {
  type        = string
  description = "Glance image name"
}

variable "flavor_name" {
  type        = string
  description = "Nova compute flavor name"
}

variable "volume_size_gb" {
  type        = number
  description = "Size of the web root volume in GB"
  default     = 20
}

variable "volume_type" {
  type        = string
  description = "Cinder volume type"
  default     = ""
}

variable "network_id" {
  type        = string
  description = "UUID of the network"
}

variable "subnet_id" {
  type        = string
  description = "UUID of the subnet"
}

variable "db_private_ip" {
  type        = string
  description = "Private IP of the Database tier"
  default     = ""
}

variable "external_floating_ip_pool" {
  type        = string
  description = "External network pool name for Floating IP"
  default     = "external-network"
}

variable "keypair_name" {
  type        = string
  description = "Keypair name"
  default     = "multitier-keypair"
}

variable "ssh_public_key" {
  type        = string
  description = "Optional public key"
  default     = ""
}
