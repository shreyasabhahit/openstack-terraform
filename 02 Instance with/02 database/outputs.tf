output "db_instance_id" {
  description = "UUID of the Database instance"
  value       = openstack_compute_instance_v2.db_instance.id
}

output "db_instance_name" {
  description = "Name of the Database instance"
  value       = openstack_compute_instance_v2.db_instance.name
}

output "db_private_ip" {
  description = "Internal IP address of Database instance"
  value       = openstack_networking_port_v2.db_port.all_fixed_ips[0]
}

output "db_security_group_id" {
  description = "UUID of Database security group"
  value       = openstack_networking_secgroup_v2.db_secgroup.id
}
