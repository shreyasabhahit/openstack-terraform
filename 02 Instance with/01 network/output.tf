output "network_id" {
  description = "UUID of the created private network"
  value       = openstack_networking_network_v2.network.id
}

output "subnet_id" {
  description = "UUID of the created private subnet"
  value       = openstack_networking_subnet_v2.subnet.id
}

output "router_id" {
  description = "UUID of the created router"
  value       = openstack_networking_router_v2.router.id
}
