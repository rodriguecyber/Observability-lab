# -----------------------------------------------------------------------------
# CloudWatch Log Group for container logs (Docker awslogs driver)
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "app" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/${var.name_prefix}/app"
  retention_in_days  = var.cloudwatch_log_retention_days
}
