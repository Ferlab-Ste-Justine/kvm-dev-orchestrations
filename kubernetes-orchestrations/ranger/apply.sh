#!/usr/bin/env bash

cp ../../shared/postgres_ca.crt .

helm template ranger-starrocks ./ranger-starrocks/helm -n ranger-starrocks --include-crds -f values.yml > ranger.yml

kubectl --kubeconfig="../../shared/kubeconfig" --context="kubernetes-admin-ferlab@ferlab" apply -k .