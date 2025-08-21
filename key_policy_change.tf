# -----------------------------------------------------------------------------
# File: key_policy_change.tf
# Purpose: Detect KMS PutKeyPolicy events via CloudTrail Logs and raise an alarm.
# Owner: ZTMF (CMS)
# Notes:
#   - Update locals.tf to match your CloudTrail log group name
#   - SNS topic is defined in shared_resources.tf
#   - Last updated: 2025-08-13
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "key_policy_change" {
  name           = "kms_key_policy_change"
  log_group_name = local.cloudtrail_log_group
  pattern        = "{ ($.eventSource = \"kms.amazonaws.com\") && ($.eventName = \"PutKeyPolicy\") }"
  metric_transformation {
    name      = "KeyPolicyChanged"
    namespace = "KMSMonitoring"
    value     = "1"
  }
}
resource "aws_cloudwatch_metric_alarm" "key_policy_change_alarm" {
  alarm_name          = "${local.org_prefix}-KMSKeyPolicyChanged"
  alarm_description   = "Triggers when a KMS key policy is changed."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = local.alarm_evaluation_periods
  metric_name         = "KeyPolicyChanged"
  namespace           = "KMSMonitoring"
  period              = local.alarm_period
  statistic           = local.alarm_statistic
  threshold           = local.alarm_threshold
  treat_missing_data  = local.alarm_treat_missing_data
  alarm_actions       = [aws_sns_topic.kms_alerts.arn]
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.org_prefix}-KMSKeyPolicyChanged"
    }
  )
}















