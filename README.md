# Terraform KMS Alerts Repository

## 📋 Overview

This educational repository provides a comprehensive set of Terraform configurations for monitoring and alerting on AWS Key Management Service (KMS) activities. It demonstrates best practices for detecting potentially suspicious or unauthorized KMS operations through CloudWatch metrics and alarms.

### Key Features

- **🔐 Security Monitoring**: Detect unauthorized access attempts, key policy changes, and scheduled key deletions
- **🌍 Regional Compliance**: Alert when KMS operations occur outside trusted regions
- **🔄 Automated Remediation**: Lambda function to automatically enable key rotation via AWS Config
- **📧 Email Notifications**: SNS-based alerting for immediate security notifications
- **⚙️ Configuration Management**: Centralized configuration using Terraform locals

## 🏗️ Repository Structure

```
.
├── locals.tf                    # Centralized configuration values
├── shared_resources.tf          # Shared SNS topic and subscriptions
├── enable_key_rotation.tf       # Lambda for automatic key rotation remediation
├── key_policy_change.tf         # Alert for KMS key policy modifications
├── kms_untrusted_region.tf      # Alert for KMS usage in untrusted regions
├── schedule_key_deletion.tf     # Alert for scheduled key deletions
├── unauthorized_kms_access.tf   # Alert for unauthorized KMS access attempts
└── Makefile                     # Development workflow automation
```

## 🚀 Quick Start

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd ZTMF-Terraform-KMS-Alerts
   ```

2. **Customize your configuration** by editing `locals.tf`:
   ```hcl
   locals {
     org_prefix = "YourOrgName"              # Replace with your organization name
     alert_emails = [
       "security-team@yourorg.com",          # Add your email addresses
       "ops-team@yourorg.com"
     ]
     cloudtrail_log_group = "your-cloudtrail-logs"  # Your CloudTrail log group
     trusted_regions = ["us-east-1", "us-west-2"]   # Your approved regions
   }
   ```

3. **Validate and deploy**:
   ```bash
   make test              # Run all validation checks
   terraform init         # Initialize Terraform
   terraform plan         # Review planned changes
   terraform apply        # Deploy the infrastructure
   ```

## 🛠️ Using the Makefile

The included Makefile provides a standardized development workflow that works across Windows, macOS, and Linux:

### Basic Commands

| Command | Description |
|---------|-------------|
| `make help` | Display all available commands |
| `make fmt` | Format all Terraform files to canonical style |
| `make validate` | Validate Terraform syntax and configuration |
| `make lint` | Run TFLint for best practices checking |
| `make security` | Run security scanners (tfsec, Checkov) |
| `make test` | Run all quality checks (fmt, validate, lint, security) |
| `make clean` | Remove temporary files and directories |

### Tool Management

| Command | Description |
|---------|-------------|
| `make tools` | Check which tools are installed |
| `make install` | Show installation instructions for required tools |

### Example Workflow

```bash
# Check your environment
make tools

# Format and validate your code
make fmt
make validate

# Run security checks
make security

# Run all checks at once
make test
```

The Makefile automatically:
- Detects your operating system (Windows/macOS/Linux)
- Checks if required tools are installed before running commands
- Provides helpful error messages if tools are missing
- Works in Git Bash, WSL, and native terminals

## 🔧 Understanding Locals

The `locals.tf` file centralizes all configuration values, making the solution easily customizable without modifying multiple files. This follows Terraform best practices for configuration management.

### Key Configuration Areas

1. **Organization Settings**:
   ```hcl
   org_prefix = "ADOName"  # Used in resource naming
   ```
   This prefix is prepended to all resource names for easy identification.

2. **Alert Recipients**:
   ```hcl
   alert_emails = [
     "security-team@example.com",
     "ops-team@example.com"
   ]
   ```
   Add all email addresses that should receive KMS security alerts.

3. **CloudTrail Integration**:
   ```hcl
   cloudtrail_log_group = "cms-cloud-cloudtrail-logs"
   ```
   Specify your existing CloudTrail log group name.

4. **Regional Compliance**:
   ```hcl
   trusted_regions = ["us-east-1", "us-west-2"]
   ```
   Define which AWS regions are approved for KMS operations.

5. **Common Tags**:
   ```hcl
   common_tags = {
     Project     = "KMS-Monitoring"
     Environment = "Production"
     ManagedBy   = "Terraform"
   }
   ```
   Tags applied to all resources for organization and cost tracking.

### How Locals Are Used

Throughout the Terraform files, locals are referenced using the `local.` prefix:

```hcl
# Example from enable_key_rotation.tf
resource "aws_iam_role" "kms_rotation_lambda_exec" {
  name = "${local.iam_role_prefix}-kms-rotation-lambda"  # Uses local.iam_role_prefix
  ...
}

# Example from shared_resources.tf
resource "aws_sns_topic_subscription" "kms_alert_emails" {
  for_each = toset(local.alert_emails)  # Iterates over local.alert_emails
  ...
}
```

This approach provides:
- **Single source of truth**: Change once, apply everywhere
- **Environment flexibility**: Easy to maintain dev/staging/prod configurations
- **Reduced errors**: No need to search and replace across multiple files
- **Better documentation**: Clear understanding of what can be customized

## 📊 Monitored KMS Events

| Alert | Description | File |
|-------|-------------|------|
| **Key Policy Changes** | Detects when KMS key policies are modified | `key_policy_change.tf` |
| **Untrusted Region Usage** | Alerts when KMS operations occur outside approved regions | `kms_untrusted_region.tf` |
| **Scheduled Key Deletion** | Notifies when KMS keys are scheduled for deletion | `schedule_key_deletion.tf` |
| **Unauthorized Access** | Detects access denied or unauthorized KMS operations | `unauthorized_kms_access.tf` |
| **Key Rotation Remediation** | Automatically enables key rotation via AWS Config | `enable_key_rotation.tf` |

## 📦 Prerequisites

- **Terraform**: >= 0.12
- **AWS Provider**: >= 3.0
- **AWS Resources Required**:
  - Active CloudTrail with CloudWatch Logs integration
  - Appropriate IAM permissions for creating resources
  - For Lambda deployment: `lambda_function_payload.zip` containing Python handler

## 🔒 Security Considerations

1. **Email Confirmation**: SNS email subscriptions require manual confirmation
2. **IAM Permissions**: Ensure deployment credentials have appropriate permissions
3. **Key Rotation Lambda**: Requires `lambda_function_payload.zip` with proper handler
4. **Log Group Access**: CloudWatch Logs must be receiving CloudTrail events

## 🤝 Contributing

This is an educational repository designed to demonstrate KMS monitoring patterns. Feel free to:
- Fork and customize for your organization
- Submit issues for bugs or improvements
- Share your own KMS monitoring patterns

## 📄 License

This repository is provided for educational purposes. Please review and test thoroughly before using in production environments.

## 🏢 Owner

**ZTMF (CMS)** - Zero Trust Management Framework

---

*Note: Remember to update `locals.tf` with your organization-specific values before deployment.*