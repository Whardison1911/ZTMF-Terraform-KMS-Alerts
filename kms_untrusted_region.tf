# -----------------------------------------------------------------------------
# File: kms_untrusted_region.tf
# Purpose: Detect KMS operations in untrusted regions and raise an alarm.
# Owner: ZTMF (CMS)
# Notes:
#   - Update locals.tf to define your trusted regions
#   - SNS topic is defined in shared_resources.tf
#   - Last updated: 2025-08-13
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "kms_untrusted_region_usage" {
  name           = "kms_untrusted_region_usage"
  log_group_name = local.cloudtrail_log_group
  
  # Pattern checks if KMS events are NOT in trusted regions
  # Note: CloudWatch Logs doesn't support dynamic array values, so regions must be hardcoded
  # Update this pattern if you change trusted_regions in locals.tf
  pattern        = "{ $.eventSource = \"kms.amazonaws.com\" && !($.awsRegion in [\"${join("\",\"", local.trusted_regions)}\"]) }"

  metric_transformation {
    name      = "KMSUntrustedRegionUsage"
    namespace = "KMSMonitoring"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "kms_untrusted_region_usage_alarm" {
  alarm_name          = "${local.org_prefix}-KMSUntrustedRegionUsage"
  alarm_description   = "Triggers when KMS operations occur in untrusted regions."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = local.alarm_evaluation_periods
  metric_name         = "KMSUntrustedRegionUsage"
  namespace           = "KMSMonitoring"
  period              = local.alarm_period
  statistic           = local.alarm_statistic
  threshold           = local.alarm_threshold
  treat_missing_data  = local.alarm_treat_missing_data
  alarm_actions       = [aws_sns_topic.kms_alerts.arn]
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.org_prefix}-KMSUntrustedRegionUsage"
    }
  )
}
