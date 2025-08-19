# -----------------------------------------------------------------------------
# File: unauthorized_kms_access.tf
# Purpose: Detect unauthorized KMS access attempts and raise CloudWatch alarms.
# Owner: ZTMF (CMS)
# Notes:
#   - Update locals.tf to match your CloudTrail log group name
#   - SNS topic is defined in shared_resources.tf
#   - Last updated: 2025-08-13
#   - Pattern uses wildcards and is console-compatible.
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "unauthorized_kms_access" {
  name           = "unauthorized_kms_access"
  log_group_name = local.cloudtrail_log_group

  # Console-ready pattern (copy/paste into AWS Console):
  # { ($.eventSource = "kms.amazonaws.com") && ( $.errorCode = "*Unauthorized*" || $.errorCode = "*AccessDenied*" || $.errorMessage = "*not authorized*" || $.errorMessage = "*Not authorized*" ) }
  #
  # Terraform-compatible version:
  pattern = "{ ($.eventSource = \"kms.amazonaws.com\") && ( $.errorCode = \"*Unauthorized*\" || $.errorCode = \"*AccessDenied*\" || $.errorMessage = \"*not authorized*\" || $.errorMessage = \"*Not authorized*\" ) }"

  metric_transformation {
    name      = "KMSUnauthorizedAccess"
    namespace = "KMSMonitoring"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_kms_access_alarm" {
  alarm_name          = "${local.org_prefix}-KMSUnauthorizedAccess"
  alarm_description   = "Triggers when an unauthorized KMS access attempt is detected."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = local.alarm_evaluation_periods
  metric_name         = "KMSUnauthorizedAccess" # must match metric_transformation.name
  namespace           = "KMSMonitoring"
  period              = local.alarm_period
  statistic           = local.alarm_statistic
  threshold           = local.alarm_threshold
  treat_missing_data  = local.alarm_treat_missing_data
  alarm_actions       = [aws_sns_topic.kms_alerts.arn]
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.org_prefix}-KMSUnauthorizedAccess"
    }
  )
}
