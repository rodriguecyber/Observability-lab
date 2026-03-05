# Observability Stack – AWS Infrastructure

Terraform deploys a single EC2 instance (Ubuntu 22.04) that runs the observability stack via Docker Compose: app, Prometheus, Grafana, Node Exporter. Optional: CloudWatch Logs, CloudTrail (S3), GuardDuty.

## Layout

- **main.tf** – Provider, data sources (AMI, VPC), observability module call
- **variables.tf** – Input variables
- **outputs.tf** – EC2 public IP, Grafana URL, Prometheus URL
- **ec2.tf** – User_data template (calls `scripts/setup.sh`)
- **iam.tf** – IAM role and instance profile (CloudWatch Logs, S3)
- **cloudwatch.tf** – CloudWatch log group for container logs
- **s3.tf** – S3 bucket for CloudTrail (encryption, lifecycle 30d → IA)
- **cloudtrail.tf** – CloudTrail trail
- **guardduty.tf** – GuardDuty detector
- **modules/observability/** – EC2 instance, security group, user_data

## Prerequisites

- AWS CLI configured (or env vars)
- EC2 key pair in the target region (create in Console or `aws ec2 create-key-pair`)
- GitHub repo with `docker-compose.yml` (and optional `docker-compose.cloudwatch.yml`) at repo root

## Usage

```bash
cd infrastructure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set key_name and github_repo_url
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Outputs: `ec2_public_ip`, `grafana_url`, `prometheus_url`, `app_url`, `ssh_command`.

## Security group

- 22 (SSH), 3000 (Grafana), 9090 (Prometheus), 9100 (Node Exporter), 4000 (app; override with `app_port` e.g. 8080)

## Provisioning (user_data)

`scripts/setup.sh` is rendered by Terraform and runs on first boot:

1. Install Docker and Docker Compose (plugin)
2. Clone the GitHub repo
3. `docker compose up -d` (or with CloudWatch override if log group is set)

## CI/CD (Jenkins)

The root `Jenkinsfile` can run Terraform from the pipeline:

1. **Parameter `DEPLOY_INFRA`** – set to `true` to run the "Deploy Infrastructure (Terraform)" stage; `false` runs only checkout, test, and optional Docker build/push.
2. **Jenkins credentials** (for Terraform stage):
   - `aws-access-key-id` – Secret text, value = AWS access key ID.
   - `aws-secret-access-key` – Secret text, value = AWS secret access key.
3. **Terraform** must be installed on the Jenkins agent (or run in a container that has Terraform).
4. **`infrastructure/terraform.tfvars`** – should exist in the repo (or be generated in the job) with `key_name`, `github_repo_url`, etc. Do not commit secrets; use Jenkins credentials for AWS only.

Pipeline runs `terraform init`, `terraform plan -out=tfplan`, `terraform apply -auto-approve tfplan` inside `infrastructure/`.

## Optional: disable CloudTrail / GuardDuty / CloudWatch

Set in `terraform.tfvars`:

- `enable_cloudtrail = false` – no S3 bucket or trail (e.g. SCP denies `s3:CreateBucket`)
- `enable_guardduty = false` – no GuardDuty resource (e.g. detector already exists or SCP denies it)
- `enable_cloudwatch_logs = false` – no log group; containers won’t use awslogs
