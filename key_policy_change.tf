# -----------------------------------------------------------------------------
# File: key_policy_change.tf
# Purpose: Detect KMS PutKeyPolicy events via CloudTrail Logs and raise an alarm.
# Owner: ZTMF (CMS)
# Notes:
#   - CloudTrail Log Group must be "cms-cloud-cloudtrail-logs"
#   - Creates a metric filter and an alarm that publishes to an SNS topic.
#   - Last updated: 2025-08-13
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "key_policy_change" {
  name           = "kms_key_policy_change"
  log_group_name = "cms-cloud-cloudtrail-logs"
  pattern        = "{ ($.eventSource = \"kms.amazonaws.com\") && ($.eventName = \"PutKeyPolicy\") }"PutKeyPolicy\""
  metric_transformation {
    name      = "KeyPolicyChanged"
    namespace = "KMSMonitoring"
    value     = "1"
  }
}
resource "aws_cloudwatch_metric_alarm" "key_policy_change_alarm" {
  alarm_name          = "KMSKeyPolicyChanged"
  alarm_description   = "Triggers when a KMS key policy is changed."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "KeyPolicyChanged"
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
  endpoint  = "your-email@example.com"
}















