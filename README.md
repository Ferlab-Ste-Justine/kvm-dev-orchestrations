# About

This repo is meant to help the operations team troubleshoot our kvm modules locally.

External dependencies are linked via git submodules with an **ssh** link for ease of development. Interested users outside of the ferlab organization should change those **ssh** links to **https** links for the submodules to resolve properly.

# Requirements

A Linux machine with modern multi-core cpus and at least 64GB RAM is recommend.

Additionally, you will need the following:
- Terraform
- The following packages:
  - qemu-kvm
  - libvirt-clients
  - libvirt-daemon-system
  - virtinst
  - xsltproc

In addition, the **libvirtd** service should be enabled and started and your user should belong to the group **libvirt**.

# Setup

## General

In all cases, you will want to perform the following steps:
- Check the default configurations
- Fetch the git submodules
- Setup a base os image
- Setup a ferlab libvirt network
- Setup an etcd cluster
- Setup the ip/mac address space

This translates into the following steps:

1. Inspect the **shared/params.json** file and change it if needed
2. Run `git submodule update --init` to fetch the submodules
3. Go to the **image** directory and run `terraform init && terraform apply`
4. Go to the **libvirt-network** directory and run: `terraform init && terraform apply`
5. Go to the **etcd** directory and run `terraform init && terraform apply`
    1. If you get `Permission denied` errors, it's probably because SELinux is not enabled on your system and QEMU enforces it. To fix that, its security driver can be disabled (not a good security practice, but acceptable for a local environment). To do so, add `security_driver = "none"` to `/etc/libvirt/qemu.conf` and restart libvirt (`sudo systemctl restart libvirtd`).
6. Go to the **netaddr** directory and run `terraform init && terraform apply`

## Coredns

Kubernetes, opensearch and postgres/patroni will also require a coredns setup.

This translates into the following step: Go to the **coredns** directory and run `terraform init && terraform apply`

For a more seemless local experience after the coredns is running, you can temporarily add the dns' ip as **nameserver** in your **/etc/resolv.conf** file (it will always be the first assignable ip in your address range and it will use google's dns as backup for names it can't resolve). This will allow you to resolve all the domains locally against the dns.

## Kubernetes

To setup a kubernetes cluster, perform the following step: Go to the **kubernetes** directory and run `terraform init && terraform apply` (note that this operation is heavy on resources and will take several minutes)

Assuming that you added the **coredns** to your **/etc/resolv.conf** file, a **kubeconfig** file will have been generated in the **shared** directory that you can use with **kubectl** to access the kubernetes masters' api.

# Caveats

Unlike with macvtap interfaces, libvirt networks keep assignment records and don't seem to like it so much when the ip/mac address mappings change.

To work around this, the ip/mac address mappings have all been moved in the **netaddr** directory with the definition of the address spaces so that you can run **terraform destroy** in the vm repos without changing the mappings since they are located in a separate repo.

However, if you delete the etcd nodes or the netaddr records in them (either the **etcd** or **netaddr** directory), you should probably delete the libvirt network as well (**libvirt-network** directory) in order to start with a new network that has a clean state.

# Useful commands
|Command|Description
|---|---
|`virsh list --all`|List all domains
|`virsh console <domain>`|Connect to a domain (login: `ubuntu` / password: *see in **shared/params.json***)
