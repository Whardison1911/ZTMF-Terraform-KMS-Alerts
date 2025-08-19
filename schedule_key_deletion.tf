# -----------------------------------------------------------------------------
# File: schedule_key_deletion.tf
# Purpose: Detect scheduled KMS key deletions and raise CloudWatch alarms.
# Owner: ZTMF (CMS)
# Notes:
#   - Update locals.tf to match your CloudTrail log group name
#   - SNS topic is defined in shared_resources.tf
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "kms_deletion_filter" {
  name           = "kms_key_deletion_filter"
  log_group_name = local.cloudtrail_log_group
  pattern        = "{ ($.eventSource = \"kms.amazonaws.com\") && ($.eventName = \"ScheduleKeyDeletion\") }"

  metric_transformation {
    name      = "KMSScheduleKeyDeletion"
    namespace = "KMSMonitoring"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "kms_key_deletion_alarm" {
  alarm_name          = "${local.org_prefix}-KMSKeyDeletionAttempt"
  alarm_description   = "Triggers when a KMS key deletion is scheduled."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = local.alarm_evaluation_periods
  metric_name         = "KMSScheduleKeyDeletion" # must match metric_transformation.name
  namespace           = "KMSMonitoring"
  period              = local.alarm_period
  statistic           = local.alarm_statistic
  threshold           = local.alarm_threshold
  treat_missing_data  = local.alarm_treat_missing_data
  alarm_actions       = [aws_sns_topic.kms_alerts.arn]
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.org_prefix}-KMSKeyDeletionAttempt"
    }
  )
}










