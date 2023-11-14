global:
  scrape_interval: 10s
  evaluation_interval: 10s

rule_files:
  - rules/coredns.yml
  - rules/etcd.yml
  - rules/prometheus.yml
  - rules/alertmanager.yml
  - rules/dhcp.yml

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