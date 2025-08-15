# -----------------------------------------------------------------------------
# File: unauthorized_kms_access.tf
# Purpose: Detect unauthorized KMS access attempts and raise CloudWatch alarms.
# Owner: ZTMF (CMS)
# Notes:
#   - CloudTrail Log Group must be "cms-cloud-cloudtrail-logs"
#   - Creates a metric filter and an alarm that publishes to an SNS topic.
#   - Last updated: 2025-08-13
#   - Pattern uses wildcards and is console-compatible.
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "unauthorized_kms_access" {
  name           = "unauthorized_kms_access"
  log_group_name = "cms-cloud-cloudtrail-logs"

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
  alarm_name          = "KMSUnauthorizedAccess"
  alarm_description   = "Triggers when an unauthorized KMS access attempt is detected."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "KMSUnauthorizedAccess" # must match metric_transformation.name
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
