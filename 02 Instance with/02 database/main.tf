data "openstack_images_image_v2" "image" {
  name = var.image_name
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.keypair_name
  public_key = var.ssh_public_key != "" ? var.ssh_public_key : null
}

resource "openstack_networking_secgroup_v2" "db_secgroup" {
  name        = "${var.instance_name}-secgroup"
  description = "Security group for Database Tier"
}

resource "openstack_networking_secgroup_rule_v2" "db_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.db_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "db_rule_mysql" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.db_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "db_rule_postgres" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.db_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "db_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.db_secgroup.id
}

resource "openstack_networking_port_v2" "db_port" {
  name           = "${var.instance_name}-port"
  network_id     = var.network_id
  admin_state_up = true
  security_group_ids = [
    openstack_networking_secgroup_v2.db_secgroup.id
  ]
  fixed_ip {
    subnet_id = var.subnet_id
  }
}

resource "openstack_blockstorage_volume_v3" "db_volume" {
  name        = "${var.instance_name}-boot-vol"
  description = "Boot volume for Database instance"
  size        = var.volume_size_gb
  image_id    = data.openstack_images_image_v2.image.id
  volume_type = var.volume_type != "" ? var.volume_type : null
}

resource "openstack_compute_instance_v2" "db_instance" {
  name        = var.instance_name
  flavor_name = var.flavor_name
  key_pair    = openstack_compute_keypair_v2.keypair.name

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.db_volume.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.db_port.id
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Tier: Database Tier" > /tmp/stellaris-tier.txt
    echo "Private IP: ${openstack_networking_port_v2.db_port.all_fixed_ips[0]}" >> /tmp/stellaris-tier.txt
    echo "Welcome to Database Tier (${var.instance_name})" > /etc/motd
  EOF
}
