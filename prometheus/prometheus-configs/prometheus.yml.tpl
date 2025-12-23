global:
  scrape_interval: 10s
  evaluation_interval: 10s

%{ if alertmanager_enabled ~}
alerting:
  alertmanagers:
    - scheme: https
      tls_config:
        ca_file: /opt/alertmanager/ca.crt
        cert_file: /opt/alertmanager/client.crt
        key_file: /opt/alertmanager/client.key
      static_configs:
        - targets:
          - server-1.alertmanager.ferlab.lan:9093
          - server-2.alertmanager.ferlab.lan:9093
%{ endif ~}

scrape_configs:
%{ if host_ip != "" ~}
%{ if physical_host.prometheus_gateway ~}
  - job_name: "physical-host-pushgateway"
    honor_labels: true
    static_configs:
      - targets:
          - "${host_ip}:9091"
    scheme: https
    tls_config:
      ca_file: /opt/physical-host-pushgateway/ca.crt
      cert_file: /opt/physical-host-pushgateway/client.crt
      key_file: /opt/physical-host-pushgateway/client.key
%{ endif ~}
%{ if physical_host.node_exporter ~}
  - job_name: "physical-host-node-exporter"
    static_configs:
      - targets:
          - "${host_ip}:9100"
    scheme: http
%{ endif ~}
%{ if physical_host.libvirt_exporter ~}
  - job_name: "physical-host-libvirt-exporter"
    static_configs:
      - targets:
          - "${host_ip}:9000"
    scheme: http
%{ endif ~}
%{ endif ~}
  - job_name: "prometheus"
    static_configs:
      - targets:
          - "prometheus.ferlab.lan:9090"
  - job_name: "prometheus-node-exporter"
    static_configs:
      - targets:
          - "prometheus.ferlab.lan:9100"
  - job_name: "alertmanager-node-exporter"
    dns_sd_configs:
      - names:
          - alertmanager.ferlab.lan
        refresh_interval: 5s
        type: A
        port: 9100
  - job_name: "etcd-node-exporter"
    dns_sd_configs:
      - names:
          - etcd.ferlab.lan
        refresh_interval: 5s
        type: A
        port: 9100
  - job_name: "coredns-node-exporter"
    dns_sd_configs:
      - names:
          - ns.ferlab.lan
        refresh_interval: 5s
        type: A
        port: 9100
  - job_name: "dhcp-node-exporter"
    dns_sd_configs:
      - names:
          - dhcp.ferlab.lan
        refresh_interval: 5s
        type: A
        port: 9100
  - job_name: "automation-server-node-exporter"
    dns_sd_configs:
      - names:
          - automation.ferlab.lan
        refresh_interval: 5s
        type: A
        port: 9100
  - job_name: "ops-etcd-exporter"
    static_configs:
      - targets:
%{ for address in etcd_addresses ~}
          - "${address.ip}:2379"
%{ endfor ~}
    scheme: https
    tls_config:
      ca_file: /opt/etcd/ca.crt
  - job_name: "automation-server-pushgateway"
    dns_sd_configs:
      - names:
          - automation.ferlab.lan
        refresh_interval: 5s
        type: A
        port: 9091
    honor_labels: true
    scheme: https
    tls_config:
      ca_file: /opt/automation-server-pushgateway/ca.crt
      cert_file: /opt/automation-server-pushgateway/client.crt
      key_file: /opt/automation-server-pushgateway/client.key
  - job_name: "ops-patroni-exporter"
    dns_sd_configs:
      - names:
          - server.postgres.ferlab.lan
        refresh_interval: 5s
        type: A
        port: 4443
    honor_labels: true
    scheme: https
    tls_config:
      ca_file: /opt/patroni/ca.crt
      cert_file: /opt/patroni/client.crt
      key_file: /opt/patroni/client.key
%{ if kubernetes_cluster_federation ~}
  - job_name: "kubernetes-cluster-federation"
    honor_labels: true
    metrics_path: /federate
    params:
      match[]:
        - '{__name__=~"kube_pod_container_resource_.*"}'
        - '{__name__="kube_pod_container_info"}'
        - '{__name__="kube_pod_status_phase"}'
        - '{__name__="container_cpu_usage_seconds_total"}'
        - '{__name__="container_memory_working_set_bytes"}'
        - '{__name__="container_start_time_seconds"}'
    static_configs:
      - targets: [prometheus.k8.ferlab.lan]
        labels:
          cluster: local
%{ endif ~}
%{ if minio_cluster_monitoring ~}
  - job_name: "minio-cluster-monitoring"
    metrics_path: /minio/v2/metrics/cluster
    scheme: https
    tls_config:
      ca_file: /opt/minio/ca.crt
    static_configs:
      - targets: [minio.ferlab.lan:9000]
        labels:
          cluster: local
%{ endif ~}
%{ if starrocks_cluster_monitoring ~}
  - job_name: "starrocks-cluster-monitoring"
    metrics_path: /metrics
    dns_sd_configs:
      - names:
          - frontends.starrocks.ferlab.lan
        refresh_interval: 5s
        type: A
        port: 8030
      - names:
          - backends.starrocks.ferlab.lan
        refresh_interval: 5s
        type: A
        port: 8040
    relabel_configs:
      - source_labels: [__address__]
        regex: .*:8030$
        target_label: group
        replacement: fe
      - source_labels: [__address__]
        regex: .*:8040$
        target_label: group
        replacement: be
%{ endif ~}
