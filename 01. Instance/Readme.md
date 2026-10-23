# OpenStack Complete Infrastructure Module

A complete, self-contained OpenTofu / Terraform module for OpenStack that provisions end-to-end infrastructure from scratch:

1. **Private Network & Subnet** with custom CIDR and DNS nameservers.
2. **Router & External Gateway** attaching the subnet to your cloud's public network.
3. **Security Group** with SSH (22), HTTP (80), and ICMP ingress rules.
4. **Keypair** with automatic Nova key generation if no public key is provided.
5. **Dedicated Port** bound to the private subnet and security group.
6. **Volume-Backed Compute Instance** compatible with both local-disk and 0-disk clouds.
7. **Floating IP** allocated from the external pool and associated to the instance port. -- commented out 
