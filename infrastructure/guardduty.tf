# -----------------------------------------------------------------------------
# GuardDuty: reference existing detector (one per account/region; do not create)
# -----------------------------------------------------------------------------
data "aws_guardduty_detector" "main" {}
