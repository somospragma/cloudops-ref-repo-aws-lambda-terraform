###########################################
################ Outputs ##################
###########################################

###########################################
############ Lambda Functions #############
###########################################

output "lambda_functions" {
  description = "Complete information about all Lambda functions created"
  value = {
    for k, v in local.all_lambda_functions : k => {
      arn                = v.arn
      function_name      = v.function_name
      invoke_arn         = v.invoke_arn
      qualified_arn      = v.qualified_arn
      version           = v.version
      last_modified     = v.last_modified
      source_code_hash  = v.source_code_hash
      source_code_size  = v.source_code_size
      log_group_arn     = aws_cloudwatch_log_group.lambda_logs[k].arn
      log_group_name    = aws_cloudwatch_log_group.lambda_logs[k].name
      source_type       = var.lambda_functions[k].type
    }
  }
}

output "lambda_function_arns" {
  description = "Map of function configuration keys to their AWS Lambda Function ARNs"
  value = {
    for k, v in local.all_lambda_functions : k => v.arn
  }
}

output "lambda_function_names" {
  description = "Names of all Lambda functions"
  value = {
    for k, v in local.all_lambda_functions : k => v.function_name
  }
}

output "lambda_invoke_arns" {
  description = "Invoke ARNs for API Gateway integration"
  value = {
    for k, v in local.all_lambda_functions : k => v.invoke_arn
  }
}

###########################################
########## CloudWatch Logs ################
###########################################

output "lambda_log_groups" {
  description = "CloudWatch Log Groups for Lambda functions"
  value = {
    for k, v in aws_cloudwatch_log_group.lambda_logs : k => {
      arn  = v.arn
      name = v.name
    }
  }
}

output "lambda_log_group_arns" {
  description = "ARNs of CloudWatch Log Groups"
  value = {
    for k, v in aws_cloudwatch_log_group.lambda_logs : k => v.arn
  }
}

###########################################
############## Permissions ################
###########################################

output "lambda_permissions" {
  description = "Lambda permissions created"
  value = {
    for k, v in aws_lambda_permission.permissions : k => {
      statement_id  = v.statement_id
      action        = v.action
      function_name = v.function_name
      principal     = v.principal
      source_arn    = v.source_arn
    }
  }
}

###########################################
########## Summary Information ############
###########################################

output "summary" {
  description = "Summary of resources created by this module"
  value = {
    total_functions = length(local.all_lambda_functions)
    total_log_groups = length(aws_cloudwatch_log_group.lambda_logs)
    total_permissions = length(aws_lambda_permission.permissions)
    function_names  = values(local.all_lambda_functions)[*].function_name
    directory_functions = keys(aws_lambda_function.directory_functions)
    s3_functions = keys(aws_lambda_function.s3_functions)
  }
}