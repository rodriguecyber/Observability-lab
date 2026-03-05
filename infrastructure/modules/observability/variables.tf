variable "name_prefix" {
  type        = string
  description = "Prefix for resource names."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID (from subnet)."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the instance."
}

variable "ami_id" {
  type        = string
  description = "AMI ID (e.g. Ubuntu 22.04)."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name for SSH."
}

variable "iam_instance_profile_name" {
  type        = string
  description = "IAM instance profile name to attach to EC2."
}

variable "user_data" {
  type        = string
  description = "User data script (install Docker, clone repo, docker compose up)."
}

variable "app_port" { type = number }
variable "grafana_port" { type = number }
variable "prometheus_port" { type = number }
variable "node_exporter_port" { type = number }
