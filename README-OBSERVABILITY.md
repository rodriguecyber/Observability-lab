# Project 6 – Observability & Security Stack

## Quick start (local / single host)

```bash
# Install deps (for /metrics)
npm install

# Run full stack: app + Prometheus + Node Exporter + Grafana
docker compose up -d

# Endpoints
# App:        http://localhost:4000  (GET /, /health, /metrics, /simulate-error)
# Prometheus: http://localhost:9090
# Grafana:    http://localhost:3000  (admin / admin)
```

## Stack

| Service       | Port  | Role                                      |
|---------------|-------|-------------------------------------------|
| app           | 4000  | Web app; exposes `/metrics` (Prometheus)  |
| prometheus    | 9090  | Scrapes app + node-exporter + self        |
| node-exporter| 9100  | Host metrics                              |
| grafana       | 3000  | Dashboards + Prometheus datasource        |

## Alerts (Prometheus)

- **HighErrorRate**: 5xx rate > 5% for 2 minutes.
- **AppDown**: App target down for 1 minute.

View in Prometheus → Alerts, or configure Alertmanager/Grafana for notifications.

## Trigger high error rate (test alert)

```bash
# Generate 5xx traffic (run for 2+ minutes to trigger HighErrorRate)
while true; do curl -s -o /dev/null http://localhost:4000/simulate-error; done
# In another terminal, mix with normal traffic: curl -s http://localhost:4000/ > /dev/null
```

## CloudWatch Logs (Docker)

Stream app container logs to CloudWatch:

1. Create log group (or use Terraform):
   ```bash
   aws logs create-log-group --log-group-name /jenkins-lab/app
   ```
2. Run with override (set `AWS_REGION` and optional `CLOUDWATCH_LOG_GROUP`):
   ```bash
   export AWS_REGION=us-east-1
   docker compose -f docker-compose.yml -f docker-compose.cloudwatch.yml up -d
   ```

IAM: instance/host needs `logs:CreateLogStream`, `logs:PutLogEvents`, `logs:DescribeLogGroups/Streams`.

## AWS (CloudTrail, S3, GuardDuty)

Terraform in `iac/terraform/`:

1. Copy `terraform.tfvars.example` to `terraform.tfvars`.
2. Set `cloudtrail_bucket_name` to a globally unique name (e.g. `123456789012-jenkins-lab-cloudtrail`).
3. Apply:
   ```bash
   cd iac/terraform
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

This creates:

- S3 bucket for CloudTrail (encryption AES-256, versioning, lifecycle: 90d → STANDARD_IA, 365d expire).
- CloudTrail trail (multi-region, log file validation).
- GuardDuty detector (enabled).
- Optional CloudWatch log group `/jenkins-lab/app` (variable `create_app_log_group`).

## Cleanup

```bash
# Stop containers
docker compose down

# Remove AWS resources
cd iac/terraform && terraform destroy
```

## Deliverables

- **prometheus.yml**: `monitoring/prometheus/prometheus.yml`
- **Grafana dashboard JSON**: `monitoring/grafana/provisioning/dashboards/json/observability.json`
- **Screenshots**: Add to `docs/screenshots/` (dashboards, alerts, CloudWatch, GuardDuty).
- **Report**: `docs/PROJECT-6-OBSERVABILITY-REPORT.md` (2-page summary).
