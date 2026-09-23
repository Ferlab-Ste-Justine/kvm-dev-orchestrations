cp ../../shared/postgres_ca.crt secrets/

kubectl --kubeconfig="../../shared/kubeconfig" --context="kubernetes-admin-ferlab@ferlab" apply -k .