kubectl --kubeconfig="../../shared/kubeconfig" --context="kubernetes-admin-ferlab@ferlab" apply -k .

cd terraform-resources && terraform init && terraform apply --auto-approve
