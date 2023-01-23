# About

This repo is meant to help the operations team troubleshoot our kvm modules locally.

External dependencies are linked via git submodules with an **ssh** link for ease of development. Interested users outside of the ferlab organization should change those **ssh** links to **https** links for the submodules to resolve properly.

# Requirements

A Linux machine with modern multi-core cpus and at least 64GB RAM is required. If you have less RAM, you can try to lower the `memory` and `count` values in **shared/params.json**. Like for 16GB RAM, a very minimal setup can work (see **shared/params_16gb-ram.json**).

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

The setup was tested successfully with Ubuntu 20.04/22.04.

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
    1. If you get `Error: failed to dial libvirt`, you can try to restart your computer (even if your user was added to the group **libvirt**, it might not be in effect yet).
    2. If you get `Error: can't find storage pool 'default'`, you will need to create a pool 'default' manually (normally created automatically when KVM is installed, but on some distributions it doesn't).
        1. To create, run this command `virsh pool-define-as default dir --target /var/lib/virt/pools/default && virsh pool-build default && virsh pool-start default && virsh pool-autostart default` (change the path as desired)
        2. To configure AppArmor for appropriate permissions, add the following under the profile in **/etc/apparmor.d/libvirt/TEMPLATE.qemu**: `"/var/lib/virt/pools/default/*" rwk,` (change the path as desired)
4. Go to the **libvirt-network** directory and run: `terraform init && terraform apply`
5. Go to the **etcd** directory and run `terraform init && terraform apply`
6. Go to the **netaddr** directory and run `terraform init && terraform apply`

## Coredns

Kubernetes, opensearch and postgres/patroni will also require a coredns setup.

This translates into the following step: Go to the **coredns** directory and run `terraform init && terraform apply`

For a more seemless local experience after the coredns is running, you can temporarily add the dns' ip as **nameserver** in your **/etc/resolv.conf** file (it will always be the first assignable ip in your address range and it will use google's dns as backup for names it can't resolve). This will allow you to resolve all the domains locally against the dns.

## Kubernetes

To setup a kubernetes cluster, perform the following step: Go to the **kubernetes** directory and run `terraform init && terraform apply` (note that this operation will take several minutes)

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
|`virsh dumpxml <domain>`|View details about a domain (in XML)
|`virsh net-list`|List networks
|`virsh net-dumpxml <network name>`|View details about a libvirt network (in XML)
|`virsh vol-list default`|List volumes in the default pool
