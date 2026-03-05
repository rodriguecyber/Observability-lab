# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-north-1"
}

variable "name_prefix" {
  description = "Prefix for resource names (e.g. observability)."
  type        = string
  default     = "observability"
}

variable "vpc_cidr" {
  description = "CIDR for the created VPC."
  type        = string
  default     = "10.0.0.0/16"
}

# -----------------------------------------------------------------------------
# EC2 (VPC is created by this stack; see vpc.tf)
# -----------------------------------------------------------------------------
variable "ami_id" {
  description = "AMI ID for EC2. Empty = use latest Ubuntu 22.04 in configured region (recommended)."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type for the monitoring host."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access."
  type        = string
}

# -----------------------------------------------------------------------------
# Ports (for security group)
# -----------------------------------------------------------------------------
variable "app_port" {
  description = "Application port (e.g. 4000 or 8080)."
  type        = number
  default     = 4000
}

variable "grafana_port" {
  description = "Grafana UI port."
  type        = number
  default     = 3000
}

variable "prometheus_port" {
  description = "Prometheus UI port."
  type        = number
  default     = 9090
}

variable "node_exporter_port" {
  description = "Node Exporter metrics port."
  type        = number
  default     = 9100
}

# -----------------------------------------------------------------------------
# Provisioning (user_data)
# -----------------------------------------------------------------------------
variable "github_repo_url" {
  description = "GitHub repo URL to clone (contains docker-compose.yml)."
  type        = string
}

variable "github_branch" {
  description = "Branch to clone."
  type        = string
  default     = "main"
}

# -----------------------------------------------------------------------------
# CloudWatch
# -----------------------------------------------------------------------------
variable "enable_cloudwatch_logs" {
  description = "Create CloudWatch log group and pass to EC2 for Docker awslogs."
  type        = bool
  default     = true
}

variable "cloudwatch_log_retention_days" {
  description = "Retention in days for the app log group."
  type        = number
  default     = 14
}

# -----------------------------------------------------------------------------
# CloudTrail (optional for SCP-restricted accounts)
# -----------------------------------------------------------------------------
variable "enable_cloudtrail" {
  description = "Create S3 bucket and CloudTrail trail."
  type        = bool
  default     = true
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail (must be globally unique). If empty and enable_cloudtrail=true, uses name_prefix-cloudtrail-<account_id>."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# GuardDuty (optional for SCP-restricted accounts)
# -----------------------------------------------------------------------------
variable "enable_guardduty" {
  description = "Enable GuardDuty (use data source if detector already exists)."
  type        = bool
  default     = true
}
