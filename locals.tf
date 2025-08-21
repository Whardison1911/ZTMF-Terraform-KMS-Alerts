# -----------------------------------------------------------------------------
# File: locals.tf
# Purpose: Centralized configuration values for KMS monitoring and alerting
# Owner: ZTMF (CMS)
# Notes:
#   - Update these values to match your environment before deployment
#   - These locals make it easy to customize the solution for your organization
# -----------------------------------------------------------------------------

locals {
  # Organization/Project naming prefix
  # Replace "ADOName" with your actual ADO/project name
  org_prefix = "ADOName"
  
  # CloudTrail log group name
  # Update this to match your existing CloudTrail log group
  cloudtrail_log_group = "cms-cloud-cloudtrail-logs"
  
  # SNS topic configuration for KMS alerts
  sns_topic_name        = "kms-alert-topic"
  sns_topic_display_name = "KMS Security Alerts"
  
  # Alert email addresses
  # Replace with your actual security team email addresses
  alert_emails = [
    "security-team@example.com",
    "ops-team@example.com"
  ]
  
  # Trusted AWS regions for KMS operations
  # Add or remove regions based on your organization's approved regions
  trusted_regions = [
    "us-east-1",
    "us-west-2"
  ]
  
  # Lambda configuration
  lambda_runtime = "python3.12"
  lambda_timeout = 60
  
  # IAM naming conventions
  iam_role_prefix   = "ct-${local.org_prefix}"
  iam_policy_prefix = "ct-${local.org_prefix}"
  
  # Common tags to apply to all resources
  common_tags = {
    Project     = "KMS-Monitoring"
    Owner       = "ZTMF"
    Environment = "Production"
    ManagedBy   = "Terraform"
    Purpose     = "KMS security monitoring and alerting"
  }
  
  # CloudWatch alarm settings
  alarm_evaluation_periods = 1
  alarm_period            = 300  # 5 minutes in seconds
  alarm_statistic         = "Sum"
  alarm_threshold         = 1
  alarm_treat_missing_data = "notBreaching"
}