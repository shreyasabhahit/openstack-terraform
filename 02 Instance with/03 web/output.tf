output "web_instance_id" {
  description = "UUID of the Web instance"
  value       = openstack_compute_instance_v2.web_instance.id
}

output "web_instance_name" {
  description = "Name of the Web instance"
  value       = openstack_compute_instance_v2.web_instance.name
}

output "web_private_ip" {
  description = "Internal IP address of Web instance"
  value       = openstack_networking_port_v2.web_port.all_fixed_ips[0]
}

output "web_floating_ip" {
  description = "Public Floating IP assigned to Web instance"
  value       = openstack_networking_floatingip_v2.web_fip.address
}

output "web_security_group_id" {
  description = "UUID of Web security group"
  value       = openstack_networking_secgroup_v2.web_secgroup.id
}
