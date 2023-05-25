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

Nfs, kubernetes, postgres/patroni and vault will also require a coredns setup.

This translates into the following step: Go to the **coredns** directory and run `terraform init && terraform apply`

For a more seemless local experience after the coredns is running, you can temporarily add the dns' ip as **nameserver** in your **/etc/resolv.conf** file (it will always be the first assignable ip in your address range and it will use google's dns as backup for names it can't resolve). This will allow you to resolve all the domains locally against the dns.

## NFS

To setup a nfs server, perform the following step: Go to the **nfs** directory and run `terraform init && terraform apply`

Note that a kubernetes orchestration can be found in the **kubernetes-orchestrations/nfs-volume** directory if needed for future troubleshooting.

## Kubernetes

To setup a kubernetes cluster, perform the following step: Go to the **kubernetes** directory and run `terraform init && terraform apply` (note that this operation will take several minutes)

Assuming that you added the **coredns** to your **/etc/resolv.conf** file, a **kubeconfig** file will have been generated in the **shared** directory that you can use with **kubectl** to access the kubernetes masters' api.

### Tunnel support

By setting the tunnel to **true** in the load balancer parameters, the load balancer will only be accessible via ssh tunneling.

A **kubernetes_tunnel_config.json** and **kubernetes_auth_secret** file will be generated in the **shared** directory, providing the required configurations for the following project: https://github.com/Ferlab-Ste-Justine/ssh-tunnel-client

## Postgres/Patroni

To setup a patroni/postgres cluster, perform the following step: Go to the **postgres** directory and run `terraform init && terraform apply`

Assuming that you added the **coredns** to your **/etc/resolv.conf** file, you can create a test database by performing the following step: Go to the **postgres-conf** directory and run `terraform init && terraform apply`

## Vault

To setup a vault cluster, perform the following step: Go to the **vault** directory and run `terraform init && terraform apply`

Assuming that you added the **coredns** to your **/etc/resolv.conf** file, you can access:
- the servers: https://vault-server-1.ferlab.lan:8200 / https://vault-server-2.ferlab.lan:8200 / https://vault-server-3.ferlab.lan:8200 / ...
- the load balancer: https://vault.ferlab.lan

Before vault is operational, it needs to be initialized and each of it's server unsealed. Example of the ui steps for 3 servers:
- Add the CA certificate found at **shared/vault-ca.crt** to your browser
- If you have set **client_auth** to **true**, add the client certificate found at **shared/vault.p12** to your browser as well
- Connect to https://vault-server-1.ferlab.lan:8200:
  - enter 1 for **Key shares** and 1 for **Key threshold** then click **Initialize**
  - take note of **Initial root token** and **Key 1** values then click **Continue to Unseal**
  - enter **Key 1** value for **Unseal Key Portion** then click **Unseal**
- Connect to https://vault-server-2.ferlab.lan:8200:
  - enter **Key 1** value for **Unseal Key Portion** then click **Unseal**
- Connect to https://vault-server-3.ferlab.lan:8200:
  - enter **Key 1** value for **Unseal Key Portion** then click **Unseal**
- Connect to https://vault.ferlab.lan:
  - enter **Initial root token** value for **Token** then click **Sign In**

### Tunnel support

By setting the tunnel to **true** in the load balancer parameters, a particuliar load balancer will be added and only be accessible via ssh tunneling.

A **vault_tunnel_config.json** and **vault_auth_secret** file will be generated in the **shared** directory, providing the required configurations for the following project: https://github.com/Ferlab-Ste-Justine/ssh-tunnel-client

Assuming that you added the **coredns** to your **/etc/resolv.conf** file, you can access:
- the servers: https://vault-tunnel.ferlab.lan:4431 / https://vault-tunnel.ferlab.lan:4432 / https://vault-tunnel.ferlab.lan:4433
- the load balancer: https://vault-tunnel.ferlab.lan

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
