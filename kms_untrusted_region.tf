resource "aws_cloudwatch_log_metric_filter" "kms_untrusted_region_usage" {
  name           = "kms_untrusted_region_usage"
  log_group_name = "/aws/cloudtrail/kms"
  pattern        = "{ $.eventSource = \"kms.amazonaws.com\" && !($.awsRegion in [\"us-east-1\",\"us-west-2\"]) }"

  metric_transformation {
    name      = "KMSUntrustedRegionUsage"
    namespace = "KMSMonitoring"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "kms_untrusted_region_usage_alarm" {
  alarm_name          = "KMSUntrustedRegionUsage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "KMSUntrustedRegionUsage"
  namespace           = "KMSMonitoring"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
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
