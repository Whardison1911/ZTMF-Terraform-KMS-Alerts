# -----------------------------------------------------------------------------
# File: shared_resources.tf
# Purpose: Shared resources used by multiple KMS alert configurations
# Owner: ZTMF (CMS)
# Notes:
#   - This file contains the common SNS topic and subscriptions
#   - Prevents duplicate resource definitions across alert files
# -----------------------------------------------------------------------------

# SNS Topic for all KMS alerts
resource "aws_sns_topic" "kms_alerts" {
  name         = local.sns_topic_name
  display_name = local.sns_topic_display_name
  
  tags = merge(
    local.common_tags,
    {
      Name = local.sns_topic_name
    }
  )
}

# SNS Email Subscriptions
# Note: Each subscription requires manual confirmation via email
resource "aws_sns_topic_subscription" "kms_alert_emails" {
  for_each = toset(local.alert_emails)
  
  topic_arn = aws_sns_topic.kms_alerts.arn
  protocol  = "email"
  endpoint  = each.value
}