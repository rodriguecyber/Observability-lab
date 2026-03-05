# Project 6 – Full Observability & Security Solution  
## 2-Page Summary Report

---

## 1. Overview

This project extends the containerized web application (from the CI/CD project) with a full observability and security stack: **Prometheus**, **Grafana**, **AWS CloudWatch Logs**, **CloudTrail**, and **GuardDuty**.

### 1.1 Components Implemented

| Component | Purpose |
|-----------|--------|
| **App `/metrics`** | Prometheus metrics (request count, latency histogram, status codes) via `prom-client`. |
| **Prometheus** | Scrapes app (`:4000/metrics`), Node Exporter (`:9100`), and self; stores 15d retention. |
| **Node Exporter** | Host metrics (CPU, memory, disk) for the monitoring EC2/container host. |
| **Grafana** | Pre-provisioned Prometheus datasource and **App Observability** dashboard (latency, RPS, error rate). |
| **Alerts** | Prometheus rule: **HighErrorRate** when 5xx rate > 5% for 2m; **AppDown** when app target is down. |
| **CloudWatch Logs** | Docker `awslogs` driver streams app container logs to log group `/jenkins-lab/app`. |
| **CloudTrail** | Multi-region trail logging account API activity to S3. |
| **S3 (CloudTrail)** | Bucket with AES-256 encryption, versioning, lifecycle (90d → STANDARD_IA, 365d expiration). |
| **GuardDuty** | Enabled with S3 protection and EBS malware protection. |

---

## 2. Verification & Evidence

### 2.1 Monitoring

- **Prometheus**: `http://<host>:9090` — Targets (app, node-exporter, prometheus) should be UP; query `rate(http_requests_total[5m])` for RPS.
- **Grafana**: `http://<host>:3000` (admin/admin) — Dashboard **App Observability** shows:
  - **Requests per second** by path/status  
  - **Error rate (5xx)** time series  
  - **Latency** p50/p95/p99 from `http_request_duration_seconds`  
  - **Current error rate** stat (threshold 5%)  
  - Node Exporter CPU panel  

### 2.2 Alerts

- **High error rate**: Generate 5xx traffic (e.g. `curl` loop to `/simulate-error`) until error rate > 5% for 2 minutes; alert appears in Prometheus **Alerts** and (if configured) in Grafana.
- **App down**: Stop the app container; **AppDown** fires after 1m.

### 2.3 CloudWatch

- **Log group**: `/jenkins-lab/app` — Log streams prefixed with `app/` contain container stdout/stderr when using `docker-compose.cloudwatch.yml`.

### 2.4 Security (AWS)

- **CloudTrail**: Events in S3 under `s3://<bucket>/AWSLogs/<account-id>/CloudTrail/`.  
- **GuardDuty**: Console → GuardDuty → Findings (may take time for first findings).  
- **S3**: Bucket policy allows only CloudTrail; encryption and lifecycle verified in bucket properties.

---

## 3. Insights & Recommendations

- **Error-rate alert (5%)**: Tuned for 2m to avoid flapping; adjust `for` and threshold per SLA.  
- **Log retention**: App log group 14 days (Terraform); CloudTrail 365d then expire; align with compliance.  
- **Cost**: GuardDuty and CloudTrail have costs; use lifecycle and retention to control S3 and log storage.  
- **Cleanup**: After verification, run `terraform destroy` in `iac/terraform` and tear down monitoring EC2/containers (e.g. `docker compose down`, terminate EC2) to avoid ongoing charges.

---

## 4. Deliverables Checklist

| Item | Location |
|------|----------|
| Prometheus config | `monitoring/prometheus/prometheus.yml` |
| Alert rules | `monitoring/prometheus/alerts.yml` |
| Grafana dashboard JSON | `monitoring/grafana/provisioning/dashboards/json/observability.json` |
| Docker + CloudWatch | `docker-compose.cloudwatch.yml` |
| CloudTrail + S3 + GuardDuty | `iac/terraform/` (Terraform) |
| Screenshots | `docs/screenshots/` (add dashboard, alerts, CloudWatch, GuardDuty) |
| This report | `docs/PROJECT-6-OBSERVABILITY-REPORT.md` |

---

*End of 2-page report.*
