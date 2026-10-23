# ==============================================================================
# OpenStack Complete Infrastructure Module
# Cleanly provisions: Network, Subnet, Router with External Gateway,
# Security Group with rules, Keypair, Network Port, Dedicated Boot Volume,
# Compute Instance with Bash Startup Script, and Floating IP.
# ==============================================================================

# 1. Image Data Lookup
data "openstack_images_image_v2" "image" {
  name = var.image_name
}

# 2. Keypair (Auto-generates 2048-bit key if ssh_public_key is empty)
resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.keypair_name
  public_key = var.ssh_public_key != "" ? var.ssh_public_key : null
}

# 3. Private Network & Subnet
resource "openstack_networking_network_v2" "network" {
  name           = var.network_name
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet" {
  name            = "${var.network_name}-subnet"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = var.subnet_cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers
  enable_dhcp     = true
}

# 4. Router & External Gateway
resource "openstack_networking_router_v2" "router" {
  name                = var.router_name
  admin_state_up      = true
  external_network_id = var.external_gateway_network_id
}

# Attach Subnet to Router Interface
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

# 5. Security Group & Ingress Firewall Rules (SSH, HTTP, HTTPS, ICMP)
resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "${var.instance_name}-secgroup"
  description = "Security group for ${var.instance_name} allowing SSH, HTTP, HTTPS, and Ping"
}

resource "openstack_networking_secgroup_rule_v2" "rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "rule_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "rule_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# 6. Dedicated Network Port (bound to subnet and security group)
resource "openstack_networking_port_v2" "port" {
  name           = "${var.instance_name}-port"
  network_id     = openstack_networking_network_v2.network.id
  admin_state_up = true
  security_group_ids = [
    openstack_networking_secgroup_v2.secgroup.id
  ]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
}

# 7. Dedicated New Cinder Boot Volume with Volume Type
resource "openstack_blockstorage_volume_v3" "boot_volume" {
  name        = "${var.instance_name}-boot-vol"
  description = "Bootable root volume for ${var.instance_name}"
  size        = var.volume_size_gb
  image_id    = data.openstack_images_image_v2.image.id
  volume_type = var.volume_type != "" ? var.volume_type : null
}

# 8. Compute Instance (Boot from Volume + Bash Startup Script)
resource "openstack_compute_instance_v2" "instance" {
  name        = var.instance_name
  flavor_name = var.flavor_name
  key_pair    = openstack_compute_keypair_v2.keypair.name

  # Boot from the newly created Cinder volume
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.boot_volume.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.port.id
  }

  # Bash Startup Script: writes message to /tmp/stellaris-welcome.txt and /etc/motd
  user_data = <<-EOF
    #!/bin/bash
    echo "==================================================" > /tmp/stellaris-welcome.txt
    echo "Instance Name: ${var.instance_name}" >> /tmp/stellaris-welcome.txt
    echo "Message: ${var.custom_welcome_message}" >> /tmp/stellaris-welcome.txt
    echo "Deployment Timestamp: $(date)" >> /tmp/stellaris-welcome.txt
    echo "==================================================" >> /tmp/stellaris-welcome.txt
    
    # Set login banner
    echo "Welcome to ${var.instance_name} (${var.custom_welcome_message})" > /etc/motd
  EOF
}

# 9. Floating IP Allocation & Safe Association (with router dependency)
resource "openstack_networking_floatingip_v2" "fip" {
pool = var.external_floating_ip_pool
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
 floating_ip = openstack_networking_floatingip_v2.fip.address
 port_id     = openstack_networking_port_v2.port.id

  # Ensure router interface is attached before associating floating IP
  depends_on = [
 openstack_networking_router_interface_v2.router_interface
]
}
