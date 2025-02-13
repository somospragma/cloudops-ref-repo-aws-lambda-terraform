resource "aws_lambda_function" "this" {
  function_name = "${var.project}-${var.client}-${var.environment}-${var.application}-${var.functionality}"
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role

  // Para desplegar el código, se utiliza el archivo ZIP ubicado en source_path
  filename         = var.source_path
  source_code_hash = filebase64sha256(var.source_path)

  memory_size = var.memory_size
  timeout     = var.timeout
  publish     = true

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = (length(var.vpc_subnet_ids) > 0 && length(var.vpc_security_group_ids) > 0) ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

}
