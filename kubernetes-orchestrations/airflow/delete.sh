  helm --kubeconfig="../../shared/kubeconfig" --kube-context="kubernetes-admin-ferlab@ferlab" uninstall airflow \
    --namespace airflow \
    --wait

kubectl --kubeconfig="../../shared/kubeconfig" --context="kubernetes-admin-ferlab@ferlab" delete namespace airflow \
  --ignore-not-found=true \
  --wait=true