###########################################
############ Local Values #################
###########################################

locals {
  # Merge all Lambda functions from both resources (only if they exist)
  all_lambda_functions = merge(
    try(aws_lambda_function.directory_functions, {}),
    try(aws_lambda_function.s3_functions, {})
  )

  # Flatten permissions from all functions with unique keys
  all_permissions = merge([
    for func_key, func in var.lambda_functions : {
      for idx, permission in func.permissions : 
      "${func_key}-${idx}" => merge(permission, {
        function_key = func_key
      })
    }
  ]...)

  # Generate standard names for functions following convention: {client}-{project}-{environment}-lambda-{map_key}
  lambda_function_names = {
    for k, v in var.lambda_functions : k => "${var.client}-${var.project}-${var.environment}-lambda-${k}"
  }

  # Generate standard names for log groups using map key: /aws/lambda/{map_key}
  log_group_names = {
    for k, v in var.lambda_functions : k => "/aws/lambda/${var.client}-${var.project}-${var.environment}-lambda-${k}"
  }
}
