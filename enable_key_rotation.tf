# -----------------------------------------------------------------------------
# File: enable_key_rotation.tf
# Purpose: Deploy a remediation Lambda that enables KMS key rotation (for use
#          with an AWS Config remediation action).
# Owner: ZTMF (CMS)
# Notes:
#   - Package `index.py` into `lambda_function_payload.zip` at the ZIP root.
#   - Handler must be `index.lambda_handler`.
#   - Update locals.tf with your organization's naming conventions
# -----------------------------------------------------------------------------

resource "aws_iam_role" "kms_rotation_lambda_exec" {
  name = "${local.iam_role_prefix}-kms-rotation-lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "kms_rotation_lambda_policy" {
  name        = "${local.iam_policy_prefix}-kms-rotation-lambda"
  description = "Allows Lambda to enable KMS key rotation and write logs."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "kms:EnableKeyRotation"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kms_rotation_lambda_attach" {
  role       = aws_iam_role.kms_rotation_lambda_exec.name
  policy_arn = aws_iam_policy.kms_rotation_lambda_policy.arn
}

resource "aws_lambda_function" "enable_kms_rotation" {
  function_name    = "${local.org_prefix}-EnableKMSKeyRotation"
  description      = "Remediation Lambda to enable KMS key rotation (invoked by AWS Config)"
  role             = aws_iam_role.kms_rotation_lambda_exec.arn
  runtime          = local.lambda_runtime
  handler          = "index.lambda_handler"
  timeout          = local.lambda_timeout
  filename         = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.org_prefix}-EnableKMSKeyRotation"
    }
  )
}

# Allow AWS Config to invoke the remediation Lambda
resource "aws_lambda_permission" "allow_config_invoke_enable_rotation" {
  statement_id  = "AllowConfigInvokeEnableRotation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.enable_kms_rotation.function_name
  principal     = "config.amazonaws.com"
}

# Remediation configuration referencing the Lambda
resource "aws_config_remediation_configuration" "kms_rotation_remediation" {
  config_rule_name = "kms-key-rotation-enabled"

  target_type = "LAMBDA"
  target_id   = aws_lambda_function.enable_kms_rotation.arn

  parameter {
    name = "ResourceId"
    resource_value {
      value = "RESOURCE_ID"
    }
  }

  automatic                  = true
  maximum_automatic_attempts = 1
  retry_attempt_seconds      = 60
}
