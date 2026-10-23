data "openstack_images_image_v2" "image" {
  name = var.image_name
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.keypair_name
  public_key = var.ssh_public_key != "" ? var.ssh_public_key : null
}

resource "openstack_networking_secgroup_v2" "web_secgroup" {
  name        = "${var.instance_name}-secgroup"
  description = "Security group for Web Tier"
}

resource "openstack_networking_secgroup_rule_v2" "web_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.web_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "web_rule_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.web_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "web_rule_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.web_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "web_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.web_secgroup.id
}

resource "openstack_networking_port_v2" "web_port" {
  name           = "${var.instance_name}-port"
  network_id     = var.network_id
  admin_state_up = true
  security_group_ids = [
    openstack_networking_secgroup_v2.web_secgroup.id
  ]
  fixed_ip {
    subnet_id = var.subnet_id
  }
}

resource "openstack_blockstorage_volume_v3" "web_volume" {
  name        = "${var.instance_name}-boot-vol"
  description = "Boot volume for Web instance"
  size        = var.volume_size_gb
  image_id    = data.openstack_images_image_v2.image.id
  volume_type = var.volume_type != "" ? var.volume_type : null
}

resource "openstack_compute_instance_v2" "web_instance" {
  name        = var.instance_name
  flavor_name = var.flavor_name
  key_pair    = openstack_compute_keypair_v2.keypair.name

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.web_volume.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.web_port.id
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Tier: Web Frontend Tier" > /tmp/stellaris-tier.txt
    echo "Database Target: ${var.db_private_ip}" >> /tmp/stellaris-tier.txt
    echo "Welcome to Web Tier (${var.instance_name}) -> DB: ${var.db_private_ip}" > /etc/motd
  EOF
}

resource "openstack_networking_floatingip_v2" "web_fip" {
  pool = var.external_floating_ip_pool
}

resource "openstack_networking_floatingip_associate_v2" "web_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.web_fip.address
  port_id     = openstack_networking_port_v2.web_port.id
}
