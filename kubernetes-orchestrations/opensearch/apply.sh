kubectl --kubeconfig="../../shared/kubeconfig" --context="kubernetes-admin-ferlab@ferlab" apply -k .

cd users_creation && terraform init && terraform apply --auto-approve