# About

This is a local orchestration to troubleshoot phenovar service.

# Required services

The local k8 deployment of phenovar requires:
- Etcd and Coredns
- Minio (with enough disk space to hold ~230GB of genomic libraries) and Vault
- Nfs (with enough disk space to hold ~300GB of data)
- Kubernetes

# Resources Requirements

The setup may not run well on your ferlab-provided laptop machine as you'll need somewhat more than 64GB RAM (depends on what else you are running on your machine) and at least ~760GB of disk space for the phenovar genomic libraries (~230GB in minio, ~300GB on your nfs server and ~230GB of local disk space if you download phenovar genomic libraries locally).

A shortcut that can be taken to save on resources (both memory and disk space) is to forgo the minio + vault part of the setup and rclone the phenovar genomic libraries directly from the QA environment to your kubernetes volume. Two important things to note if you opt to do that:
- Use minio credentials that only have read access to the phenovar genomic libraires and nothing else
- You'll be downloading ~230GB of data over your internet connection each time you bootstrap the setup. Depending on your internet speed, this could be a significant overhead

# Setup

1. In your params.json, makes sure that minio can hold ~230GB of data, uses vault, that kubernetes is setup with nfs, that the kubernetes workers have at least 12GB of RAM and that the nfs server can hold 300GB of data. Also setup nfs **fs_layout** to **phenovar**.
2. Provision minio, kubernetes and the nfs server.
3. Put read-only ferlab dockerhub credentials in the **shared/container_registry_credentials.yml** file (fields are **username** and **password**)
4. Download some dummy genomic files (nothing containing sensitive information) in a directory named following the kubernetes-orchestrations/phenovar/client/client/body.json layout (see analysis_files field)
5. Download the phenovar genomic libraries (if you take the shortcut, you can skip this step). Note that those genomic libraries don't contain any sensitive information and can be used locally.
6. Create a **kubernetes-orchestrations/phenovar/resources-rclone-setup/upload-to-s3/path** file containing the path to phenovar's genomic libraries (if you take the shortcut, you can skip this step)
7. Create a **kubernetes-orchestrations/phenovar/client-setup/upload-to-s3/path** file containing the path to the directory containing the dummy genomic files you will use to validate phenovar
8. Go to the following directories and run `terraform init & terraform apply in each`:
  - **kubernetes-orchestrations/phenovar/resources-rclone-setup/k8-dependencies** (if you take the shortcut, adjust the rclone.conf to point to the QA and not your local minio first)
  - **kubernetes-orchestrations/phenovar/resources-rclone-setup/upload-to-s3** 
  - **kubernetes-orchestrations/phenovar/redis-mysql-phenovar-setup**
  - **kubernetes-orchestrations/phenovar/redis-mysql-phenovar-setup**
  - **kubernetes-orchestrations/phenovar/client-setup/token-generation**
  - **kubernetes-orchestrations/phenovar/client-setup/upload-to-s3**
9. Go in the minio dashboard and enabled encryption for the buckets
10. Go to **kubernetes-orchestrations/phenovar/resources-rclone-setup/upload-to-s3** and run the **sync.sh** script (if you take the shortcut, you can skip this step)
11. Go to **kubernetes-orchestrations/phenovar/client-setup/upload-to-s3** and run the **sync.sh** script
12. Go to **kubernetes-orchestrations/phenovar/volumes** and run the **apply.sh** script. Wait for the rclone job (located in the phenovar-ops namespace) to complete.
13. Go to **kubernetes-orchestrations/phenovar/redis** and **kubernetes-orchestrations/phenovar/mysql** and run the **apply.sh** script in each
14. Go to **kubernetes-orchestrations/phenovar/create-databases** and run the **apply.sh** script. Make sure the job to create the databases in the **phenovar** namespace succeeded.
15. Go to **kubernetes-orchestrations/phenovar/service** and run the **apply.sh** script.
16. Go to **kubernetes-orchestrations/phenovar/client** and run the **apply.sh** script.
17. Exec in the **api-troubleshoot** container of the client job and interact with the phenovar api using the provided scripts