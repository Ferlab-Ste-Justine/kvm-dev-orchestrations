groups:
  - name: ${job.label}-terracd-metrics
    rules:
%{ if job.unit == "minute" ~}
      #${replace(job.label, "-", " ")} elapsed time since last plan
      - record: ${replace(job.label, "-", "_")}:successful_plan_interval:minutes
        expr: (time() - (max by(job ) (terracd_timestamp_seconds{job="${job.label}", command=~"apply|plan", result="success"}) OR on() vector(0))) / 60 
      #${replace(job.label, "-", " ")} elapsed time since apply
      - record: ${replace(job.label, "-", "_")}:successful_apply_interval:minutes
        expr: (time() - (terracd_timestamp_seconds{job="${job.label}", command="apply", result="success"} OR on() vector(0))) / 60 
      - alert: ${replace(title(replace(job.label, "-", " ")), " ", "")}LastPlanTooLongAgo
        expr: ${replace(job.label, "-", "_")}:successful_plan_interval:minutes > ${job.plan_interval_threshold}
        for: 15m
        annotations:
          summary: "Too Long Since Last Successful Plan For Job ${title(replace(job.label, "-", " "))}"
          description: "Last successful plan for job *${job.label}* was *{{ $value }}* minutes ago"
      - alert: ${replace(title(replace(job.label, "-", " ")), " ", "")}LastApplyTooLongAgo
        expr: ${replace(job.label, "-", "_")}:successful_apply_interval:minutes > ${job.apply_interval_threshold}
        for: 15m
        annotations:
          summary: "Too Long Since Last Successful Apply For Job ${title(replace(job.label, "-", " "))}"
          description: "Last successful apply for job *${job.label}* was *{{ $value }}* minutes ago"
%{ else ~}
      #${replace(job.label, "-", " ")} elapsed time since last plan
      - record: ${replace(job.label, "-", "_")}:successful_plan_interval:hours
        expr: (time() - (max by(job ) (terracd_timestamp_seconds{job="${job.label}", command=~"apply|plan", result="success"}) OR on() vector(0))) / 3600 
      #${replace(job.label, "-", " ")} elapsed time since apply
      - record: ${replace(job.label, "-", "_")}:successful_apply_interval:hours
        expr: (time() - (terracd_timestamp_seconds{job="${job.label}", command="apply", result="success"} OR on() vector(0))) / 3600
      - alert: ${replace(title(replace(job.label, "-", " ")), " ", "")}LastPlanTooLongAgo
        expr: ${replace(job.label, "-", "_")}:successful_plan_interval:hours > ${job.plan_interval_threshold}
        for: 15m
        annotations:
          summary: "Too Long Since Last Successful Plan For Job ${title(replace(job.label, "-", " "))}"
          description: "Last successful plan for job *${job.label}* was *{{ $value }}* hours ago"
      - alert: ${replace(title(replace(job.label, "-", " ")), " ", "")}LastApplyTooLongAgo
        expr: ${replace(job.label, "-", "_")}:successful_apply_interval:hours > ${job.apply_interval_threshold}
        for: 15m
        annotations:
          summary: "Too Long Since Last Successful Apply For Job ${title(replace(job.label, "-", " "))}"
          description: "Last successful apply for job *${job.label}* was *{{ $value }}* hours ago"
%{ endif ~}