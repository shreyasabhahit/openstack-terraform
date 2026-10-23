variable "instance_name" {
  type        = string
  description = "Name of the Database instance"
  default     = "prod-db"
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
  description = "Size of the database root volume in GB"
  default     = 30
}

variable "volume_type" {
  type        = string
  description = "Cinder volume type"
  default     = ""
}

variable "network_id" {
  type        = string
  description = "UUID of the private network"
}

variable "subnet_id" {
  type        = string
  description = "UUID of the private subnet"
}

variable "keypair_name" {
  type        = string
  description = "Keypair name"
  default     = "multitier-keypair"
}

variable "ssh_public_key" {
  type        = string
  description = "Optional SSH public key"
  default     = ""
}
