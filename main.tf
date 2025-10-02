###########################################
#             Function Resources          #
###########################################

# Local values are defined in locals.tf

# Create archive for directory-based Lambda functions
data "archive_file" "lambda_zip" {
  for_each = {
    for name, config in var.lambda_functions : name => config
    if config.type == "directory"
  }

  type        = "zip"
  source_dir  = each.value.source_path
  output_path = "${each.key}-lambda.zip"
}

# Create Lambda functions - type = "directory"
resource "aws_lambda_function" "directory_functions" {
  provider = aws.project
  for_each = {
    for name, config in var.lambda_functions : name => config
    if config.type == "directory"
  }

  function_name = local.lambda_function_names[each.key]
  description   = each.value.description
  role         = each.value.lambda_iam_role_arn
  handler      = each.value.handler
  runtime      = each.value.runtime
  memory_size  = each.value.memory_size
  timeout      = each.value.timeout

  filename         = data.archive_file.lambda_zip[each.key].output_path
  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256

  # Layers - Usa ARNs externos proporcionados
  layers = each.value.layer_arns

  # Environment variables
  dynamic "environment" {
    for_each = length(each.value.environment_variables) > 0 ? [1] : []
    content {
      variables = each.value.environment_variables
    }
  }

  # KMS encryption for environment variables
  kms_key_arn = each.value.lambda_kms_key_arn

  # VPC configuration
  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [each.value.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Sistema de etiquetado
  tags = merge(
    {
      Name = local.lambda_function_names[each.key]
    },
    each.value.additional_tags
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda_logs
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Create Lambda functions - type = "s3"
resource "aws_lambda_function" "s3_functions" {
  provider = aws.project
  for_each = {
    for name, config in var.lambda_functions : name => config
    if config.type == "s3"
  }

  function_name = local.lambda_function_names[each.key]
  description   = each.value.description
  role         = each.value.lambda_iam_role_arn
  handler      = each.value.handler
  runtime      = each.value.runtime
  memory_size  = each.value.memory_size
  timeout      = each.value.timeout

  s3_bucket        = each.value.s3_bucket
  s3_key           = each.value.s3_key
  source_code_hash = each.value.source_code_hash

  # Layers - Usa ARNs externos proporcionados
  layers = each.value.layer_arns

  # Environment variables
  dynamic "environment" {
    for_each = length(each.value.environment_variables) > 0 ? [1] : []
    content {
      variables = each.value.environment_variables
    }
  }

  # KMS encryption for environment variables
  kms_key_arn = each.value.lambda_kms_key_arn

  # VPC configuration
  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [each.value.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Sistema de etiquetado
  tags = merge(
    {
      Name = local.lambda_function_names[each.key]
    },
    each.value.additional_tags
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda_logs
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Create Lambda functions - type = "ecr"
resource "aws_lambda_function" "ecr_functions" {
  provider = aws.project
  for_each = {
    for name, config in var.lambda_functions : name => config
    if config.type == "ecr"
  }

  function_name = local.lambda_function_names[each.key]
  description   = each.value.description
  role         = each.value.lambda_iam_role_arn
  memory_size  = each.value.memory_size
  timeout      = each.value.timeout
  package_type = "Image"

  image_uri = each.value.image_uri

  # Environment variables
  dynamic "environment" {
    for_each = length(each.value.environment_variables) > 0 ? [1] : []
    content {
      variables = each.value.environment_variables
    }
  }

  # KMS encryption for environment variables
  kms_key_arn = each.value.lambda_kms_key_arn

  # VPC configuration
  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [each.value.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Sistema de etiquetado
  tags = merge(
    {
      Name = local.lambda_function_names[each.key]
    },
    each.value.additional_tags
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda_logs
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Create Lambda permissions
resource "aws_lambda_permission" "permissions" {
  provider = aws.project
  for_each = local.all_permissions

  statement_id  = each.value.statement_id
  action        = each.value.action
  function_name = local.all_lambda_functions[each.value.function_key].function_name
  principal     = each.value.principal
  source_arn    = each.value.source_arn

  depends_on = [
    aws_lambda_function.directory_functions,
    aws_lambda_function.s3_functions,
    aws_lambda_function.ecr_functions
  ]
}

###########################################
#         CloudWatch Log Groups           #
###########################################

# Create CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "lambda_logs" {
  provider = aws.project
  for_each = var.lambda_functions

  name              = local.log_group_names[each.key]
  retention_in_days = each.value.log_retention_days
  kms_key_id       = each.value.lambda_kms_key_arn

  # Sistema de etiquetado simplificado para Log Groups
  tags = {
    Name = local.log_group_names[each.key]
  }

  lifecycle {
    create_before_destroy = true
  }
}