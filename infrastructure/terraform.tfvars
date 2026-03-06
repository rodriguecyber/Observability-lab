# -----------------------------------------------------------------------------
# Copy to terraform.tfvars and set key_name + github_repo_url (required).
# -----------------------------------------------------------------------------
aws_region     = "eu-north-1"
name_prefix    = "observability"
instance_type  = "t3.medium"

# Required: existing EC2 key pair for SSH
key_name = "observability"

# Required: repo containing docker-compose.yml (observability stack)
github_repo_url = "https://github.com/rodriguecyber/Observability-lab"
github_branch   = "main"

# Optional: disable if your account has SCP restrictions
enable_cloudwatch_logs = true
enable_cloudtrail      = true
enable_guardduty       = true

# Optional: custom CloudTrail bucket name (must be globally unique)
# cloudtrail_bucket_name = "my-company-cloudtrail-123456789012"

# Application port (4000 = default in compose; use 8080 if you map in compose)
app_port = 4000
