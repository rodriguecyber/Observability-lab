# -----------------------------------------------------------------------------
# IAM role and instance profile for EC2 (CloudWatch Logs + S3)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ec2_observability" {
  name_prefix = "${var.name_prefix}-ec2-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_observability" {
  name_prefix = "${var.name_prefix}-ec2-"
  role        = aws_iam_role.ec2_observability.name
}

# CloudWatch Logs: create log stream and put events
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name_prefix = "${var.name_prefix}-logs-"
  role        = aws_iam_role.ec2_observability.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# S3: write access for CloudTrail bucket (when CloudTrail is enabled)
resource "aws_iam_role_policy" "s3_write" {
  count       = var.enable_cloudtrail ? 1 : 0
  name_prefix = "${var.name_prefix}-s3-"
  role        = aws_iam_role.ec2_observability.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:PutObjectAcl"]
        Resource = "${aws_s3_bucket.cloudtrail[0].arn}/*"
      }
    ]
  })
}
