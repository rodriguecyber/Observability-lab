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

# Resolve current Ubuntu 22.04 AMI (avoids "couldn't find resource" from deprecated static AMI)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------------------------------------------------------
# Observability EC2 stack (instance, security group, user_data)
# VPC and subnet are created in vpc.tf; module uses their IDs.
# -----------------------------------------------------------------------------
module "observability" {
  source = "./modules/observability"

  name_prefix  = var.name_prefix
  vpc_id       = aws_vpc.observability.id
  subnet_id    = aws_subnet.observability_public.id
  ami_id       = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name     = var.key_name
  iam_instance_profile_name = aws_iam_instance_profile.ec2_observability.name

  app_port           = var.app_port
  grafana_port       = var.grafana_port
  prometheus_port    = var.prometheus_port
  node_exporter_port = var.node_exporter_port

  user_data = local.observability_user_data

  depends_on = [
    aws_vpc.observability,
    aws_subnet.observability_public,
    aws_route_table_association.observability_public,
    aws_iam_instance_profile.ec2_observability,
  ]
}
