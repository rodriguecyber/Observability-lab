# -----------------------------------------------------------------------------
# VPC and public subnet for the observability EC2 instance
# -----------------------------------------------------------------------------
resource "aws_vpc" "observability" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "observability" {
  vpc_id = aws_vpc.observability.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_subnet" "observability_public" {
  vpc_id                  = aws_vpc.observability.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public"
  }
}

resource "aws_route_table" "observability_public" {
  vpc_id = aws_vpc.observability.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.observability.id
  }

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "observability_public" {
  subnet_id      = aws_subnet.observability_public.id
  route_table_id = aws_route_table.observability_public.id
}
