variable "network_name" {
  type        = string
  description = "Name of the private network to create"
  default     = "multitier-net"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet"
  default     = "192.168.20.0/24"
}

variable "dns_nameservers" {
  type        = list(string)
  description = "DNS servers for the private subnet"
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "router_name" {
  type        = string
  description = "Name of the Neutron router"
  default     = "multitier-router"
}

variable "external_gateway_network_id" {
  type        = string
  description = "UUID of the external/public network providing internet gateway access"
}
