# -----------------------------------------------------------------------------
# EC2: observability stack is created via the observability module in main.tf.
# This file holds the user_data template and module wiring.
# -----------------------------------------------------------------------------
locals {
  # Build user_data from setup script (script path relative to repo root)
  observability_user_data = templatefile("${path.module}/../scripts/setup.sh", {
    github_repo_url       = var.github_repo_url
    github_branch         = var.github_branch
    aws_region            = var.aws_region
    cloudwatch_log_group  = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.app[0].name : ""
  })
}
