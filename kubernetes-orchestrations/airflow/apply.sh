
kubectl --kubeconfig="../../shared/kubeconfig" --context="kubernetes-admin-ferlab@ferlab" create namespace airflow --dry-run=server -o yaml | kubectl --kubeconfig="../../shared/kubeconfig" --context="kubernetes-admin-ferlab@ferlab" apply -f -

helm repo add apache-airflow https://airflow.apache.org;
helm --kubeconfig="../../shared/kubeconfig" --kube-context="kubernetes-admin-ferlab@ferlab" upgrade --install airflow \
  apache-airflow/airflow \
  --namespace airflow \
  --version "1.21.0" \
  --values values.yaml