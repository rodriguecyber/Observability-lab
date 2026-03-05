# -----------------------------------------------------------------------------
# Observability EC2 module: instance, security group, user_data
# -----------------------------------------------------------------------------
resource "aws_security_group" "observability" {
  name_prefix = "${var.name_prefix}-"
  description = "Security group for observability stack (SSH, Grafana, Prometheus, Node Exporter, App)"
  vpc_id      = local.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = var.grafana_port
    to_port     = var.grafana_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = var.prometheus_port
    to_port     = var.prometheus_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter"
    from_port   = var.node_exporter_port
    to_port     = var.node_exporter_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# VPC is passed from root (no data source needed)
locals {
  vpc_id = var.vpc_id
}

resource "aws_instance" "observability" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.observability.id]
  iam_instance_profile   = var.iam_instance_profile_name
  key_name               = var.key_name

  user_data = var.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.name_prefix}-monitoring"
  }
}

# Optional: EIP for static public IP (uncomment if needed)
# resource "aws_eip" "observability" {
#   instance = aws_instance.observability.id
#   domain   = "vpc"
# }
