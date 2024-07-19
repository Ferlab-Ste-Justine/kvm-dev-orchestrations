# About

This repo is meant to help the operations team troubleshoot our kvm modules locally.

External dependencies are linked via git submodules with an **ssh** link for ease of development. Interested users outside of the ferlab organization should change those **ssh** links to **https** links for the submodules to resolve properly.

# Requirements

A Linux machine with modern multi-core cpus and at least 64GB RAM is strongly recommended.

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
- Setup the network address space in etcd to manage ips and mac addresses

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

### Assigned Ips

Whenever you run **terraform apply** in the **netaddr** directory, the **shared/ips.md** file will be updated with all currently assigned ips (minus the hardcoded ones for the etcd cluster and automation server).

This provides basic visualization of the assigned ips so far.

### Centralised Logs

We are in the process of integrating centralised logs validation for our vms in the development environment. To enable it, you need to follow the steps below:
1. Create a **host_params.json** file in the **shared** directory with the following two properties:
  - **ip**: The ip of your local machine
  - **dns**: The ip of a dns server your local machine uses
2. Set the **logs_forwarding** property to true in the **params.json** file.
3. In a separate terminal, go to the **logs** directory and run the **run.sh** script. It will run **fluentd** in a docker container that will listen for log traffic coming from the vms.

## Coredns

Nfs, kubernetes, postgres/patroni and vault will also require a coredns setup.

This translates into the following step: Go to the **coredns** directory and run `terraform init && terraform apply`

For a more seemless local experience after the coredns is running, you can temporarily add the dns' ip as **nameserver** in your **/etc/resolv.conf** file (it will always be the first assignable ip in your address range and it will use google's dns as backup for names it can't resolve). This will allow you to resolve all the domains locally against the dns.

## NFS

To setup a nfs server, perform the following step: Go to the **nfs** directory and run `terraform init && terraform apply`

Assuming that you added the **coredns** to your **/etc/resolv.conf** file, you can troubleshoot volume integration in kubernetes by running the orchestration in the **kubernetes-orchestrations/nfs-volume** directory.

## Kubernetes

To setup a kubernetes cluster, perform the following step: Go to the **kubernetes** directory and run `terraform init && terraform apply` (note that this operation will take several minutes)

Assuming that you added the **coredns** to your **/etc/resolv.conf** file, a **kubeconfig** file will have been generated in the **shared** directory that you can use with **kubectl** to access the kubernetes masters' api.

### Docker Registry Credentials

You can integrate your kubernetes installation with private Docker registry credentials (if you don't wish to be limited by image download limits while you are testing repeated kubernetes installations).

To do so, you need to create a **registry_credentials.yml** file in the **shared** directory.

The file should have the following format:

```
credentials:
  - registry: registry-1.docker.io
    username: <your username>
    password: <your password>
```

These credentials will be configured on masters/workers regarding docker for `nerdctl` commands that kubespray uses during deployment (see local value **docker_registry_auth**) as well as containerd for pods that will run in the kubernetes cluster (see local value **registry_credentials**).

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

## Minio

To setup a distributed minio, go to the **minio** directory and run `terraform init && terraform apply`.

It will setup a minio cluster consisting of 4 servers 2 disks per server (8 disks total). 

The **minio.ferlab.lan** domain will do dns load balancing on all servers. Individual servers can be fetched using the **server1.minio.ferlab.lan**, **server2.minio.ferlab.lan**, **server3.minio.ferlab.lan** and **server4.minio.ferlab.lan** domains. Here, we assume that you set up the coredns server locally as described above.

The minios are accessible on port 9000 via tls. The CA used to provision the server certificates can be found at **shared/minio_ca.crt**.

The root credentials for minio can be found in the parameters file, in the **minio** entry.

## Dhcp/pxe Server

A dhcp/pxe server can be setup on the libvirt network. It is dependent on minio running as it synchronizes with minio for os images.

In order to troubleshoot a pxe installation on a vm, you need to:
1. Start a minio cluster as outlined above
2. Go in the **dhcp-pxe-os-setup** directory, run **run.sh** (it will open a shell in a docker container) and then **setup.sh** to upload a ubuntu server image in minio. Note that it assumes that the minio domain resolves locally (ie, you have the coredns server pluged in your local environment)
3. Boot the dhcp/pxe server, by going to the **dhcp** directory and and run `terraform init && terraform apply`
4. Run the **pxe_client_setup.sh** script to start a blank vm that will be setup with the pxe server. You can interact with the prompt to install ubuntu server on the vm from the libvirt network.
5. Once you are done, you can run the **pxe_client_destroy.sh** script to cleanup the vm.

## OpenSearch

To setup an opensearch cluster, go to the **opensearch** directory and run `terraform init && terraform apply`.

Assuming that you added the **coredns** to your **/etc/resolv.conf** file, you can access opensearch REST API with this command: `curl --cacert ../shared/opensearch-ca.crt --cert ../shared/opensearch.crt --key ../shared/opensearch.key https://opensearch.ferlab.lan:9200`

# Useful commands
|Command|Description
|---|---
|`virsh list --all`|List all domains
|`virsh console <domain>`|Connect to a domain (login: `ubuntu` / password: *see in **shared/params.json***)
|`virsh dumpxml <domain>`|View details about a domain (in XML)
|`virsh net-list`|List networks
|`virsh net-dumpxml <network name>`|View details about a libvirt network (in XML)
|`virsh vol-list default`|List volumes in the default pool
