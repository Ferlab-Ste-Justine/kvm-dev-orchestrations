kubectl --kubeconfig="../../shared/kubeconfig" --context="kubernetes-admin-ferlab@ferlab" apply -k . --grace-period=0 --force

cd terraform-resources && terraform init && terraform apply --auto-approve
