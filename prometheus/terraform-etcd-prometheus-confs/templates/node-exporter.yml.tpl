groups:
  - name: ${job.label}-node-exporter-metrics
    rules:
      #${replace(job.label, "-", " ")} hosts count
      - record: ${replace(job.label, "-", "_")}:up:count
        expr: sum without(instance) (up{job="${job.label}-node-exporter"})
      - alert: Some${replace(title(replace(job.label, "-", " ")), " ", "")}Down
        expr: ${replace(job.label, "-", "_")}:up:count < ${job.expected_count}
        for: 15m
        annotations:
          summary: "${title(replace(job.label, "-", " "))} VM(s) Down"
          description: "Number of vm instances detected by job *{{ $labels.job }}* has dropped to *{{ $value }}*"
      #${replace(job.label, "-", " ")} hosts memory metrics
      - record: ${replace(job.label, "-", "_")}:total_memory:gigabytes
        expr: node_memory_MemTotal_bytes{job="${job.label}-node-exporter"} / 1024 / 1024 / 1024     
      - record: ${replace(job.label, "-", "_")}:memory_usage:percentage
        expr: (1 - (node_memory_MemFree_bytes{job="${job.label}-node-exporter"} / node_memory_MemTotal_bytes{job="${job.label}-node-exporter"}))*100
      - record: ${replace(job.label, "-", "_")}:reserved_memory_ratio:percentage
        expr: (1 - (node_memory_MemAvailable_bytes{job="${job.label}-node-exporter"} / node_memory_MemTotal_bytes{job="${job.label}-node-exporter"}))*100
      - alert: ${replace(title(replace(job.label, "-", " ")), " ", "")}MemoryUsageHigh
        expr: ${replace(job.label, "-", "_")}:reserved_memory_ratio:percentage > ${job.memory_usage_threshold}
        annotations:
          summary: "${title(replace(job.label, "-", " "))} VM(s) High Memory Usage"
          description: "Instance *{{ $labels.instance }}* of job *{{ $labels.job }}* has reserved *{{ $value }}*% of available memory"
      #${replace(job.label, "-", " ")} hosts CPU metrics
      - record: ${replace(job.label, "-", "_")}:cpu_cores:count
        expr: count without(mode, cpu) (node_cpu_seconds_total{job="${job.label}-node-exporter", mode="idle"})
      - record: ${replace(job.label, "-", "_")}:cpu_usage:percentage
        expr: (sum without(cpu, mode) (rate(node_cpu_seconds_total{job="${job.label}-node-exporter", mode!="idle"}[5m]))) / (sum without(cpu, mode) (rate(node_cpu_seconds_total{job="${job.label}-node-exporter"}[5m]))) * 100
      - alert: ${replace(title(replace(job.label, "-", " ")), " ", "")}CPUUsageHigh
        expr: ${replace(job.label, "-", "_")}:cpu_usage:percentage > ${job.cpu_usage_threshold}
        for: 15m
        annotations:
          summary: "${title(replace(job.label, "-", " "))} VM(s) High CPU Usage"
          description: "Instance *{{ $labels.instance }}* of job *{{ $labels.job }}* has been running on high CPU for a while. Currently at *{{ $value }}*% usage"
      #${replace(job.label, "-", " ")} hosts filesystem metrics
      - record: ${replace(job.label, "-", "_")}:filesystem_size:gigabytes
        expr: node_filesystem_size_bytes{job="${job.label}-node-exporter", fstype="ext4"} / 1024 / 1024 / 1024
      - record: ${replace(job.label, "-", "_")}:filesystem_space_usage_ratio:percentage
        expr: (1 - node_filesystem_avail_bytes{job="${job.label}-node-exporter", fstype="ext4"} / node_filesystem_size_bytes{job="${job.label}-node-exporter", fstype="ext4"}) * 100
      - record: ${replace(job.label, "-", "_")}:disks_io_usage:percentage
        expr: rate(node_disk_io_time_seconds_total{job="${job.label}-node-exporter", device=~"vd."}[5m]) * 100
      - alert: ${replace(title(replace(job.label, "-", " ")), " ", "")}DiskSpaceUsageHigh
        expr: ${replace(job.label, "-", "_")}:filesystem_space_usage_ratio:percentage > ${job.disk_space_usage_threshold}
        annotations:
          summary: "${title(replace(job.label, "-", " "))} VM(s) High Disk Space Usage"
          description: "Instance *{{ $labels.instance }}* of job *{{ $labels.job }}* has disk space usage *{{ $value }}*% for device *{{ $labels.device }}*"
      - alert: ${replace(title(replace(job.label, "-", " ")), " ", "")}DiskIoUsageHigh
        expr: ${replace(job.label, "-", "_")}:disks_io_usage:percentage > ${job.disk_io_usage_threshold}
        for: 15m
        annotations:
          summary: "${title(replace(job.label, "-", " "))} VM(s) High Disk Io Usage"
          description: "Instance *{{ $labels.instance }}* of job *{{ $labels.job }}* has been running high io on device *{{ $labels.device }}* for a while. Current io at *{{ $value }}*%"