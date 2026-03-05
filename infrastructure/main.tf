# -----------------------------------------------------------------------------
# Observability Stack - Root Module
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Ubuntu 22.04 LTS (amd64)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Default VPC and subnets for EC2 placement
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -----------------------------------------------------------------------------
# Observability EC2 stack (instance, security group, user_data)
# -----------------------------------------------------------------------------
module "observability" {
  source = "./modules/observability"

  name_prefix  = var.name_prefix
  vpc_id       = data.aws_vpc.default.id
  subnet_id    = var.subnet_id != "" ? var.subnet_id : tolist(data.aws_subnets.default.ids)[0]
  ami_id       = coalesce(var.ami_id, data.aws_ami.ubuntu.id)
  instance_type = var.instance_type
  key_name     = var.key_name
  iam_instance_profile_name = aws_iam_instance_profile.ec2_observability.name

  app_port           = var.app_port
  grafana_port       = var.grafana_port
  prometheus_port    = var.prometheus_port
  node_exporter_port = var.node_exporter_port

  user_data = local.observability_user_data
}
