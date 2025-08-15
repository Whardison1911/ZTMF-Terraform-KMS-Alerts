# -----------------------------------------------------------------------------
# File: schedule_key_deletion.tf
# Purpose: Detect scheduled KMS key deletions and raise CloudWatch alarms.
# Owner: ZTMF (CMS)
# Notes:
#   - CloudTrail Log Group must be "cms-cloud-cloudtrail-logs"
#   - Creates a metric filter and an alarm that publishes to an SNS topic.
#   - Last updated: 2025-08-13
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "kms_deletion_filter" {
  name           = "kms_key_deletion_filter"
  log_group_name = "cms-cloud-cloudtrail-logs"
  pattern        = "{ ($.eventSource = \"kms.amazonaws.com\") && ($.eventName = \"ScheduleKeyDeletion\") }"

  metric_transformation {
    name      = "KMSScheduleKeyDeletion"
    namespace = "KMSMonitoring"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "kms_key_deletion_alarm" {
  alarm_name          = "KMSKeyDeletionAttempt"
  alarm_description   = "Triggers when a KMS key deletion is scheduled."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "KMSScheduleKeyDeletion" # must match metric_transformation.name
  namespace           = "KMSMonitoring"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.kms_alerts.arn]
}

resource "aws_sns_topic" "kms_alerts" {
  name = "kms-alert-topic"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.kms_alerts.arn
  protocol  = "email"
  endpoint  = "your-email@example.com" # requires email confirmation
}










