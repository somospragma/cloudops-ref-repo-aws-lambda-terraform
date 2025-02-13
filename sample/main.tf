module "lambda_function" {
  source         = "./module/lambda"

  # Variables de nombramiento
  client        = var.client
  project       = var.project
  environment   = var.environment
  application   = var.application
  functionality = var.functionality

  # Configuración
  handler        = var.handler
  runtime        = var.runtime
  role           = var.role_arn
  source_path    = var.source_path
  memory_size    = var.memory_size
  timeout        = var.timeout

  environment_variables = {
    ENV = var.environment
  }

  # Asignar valores para asociar la función a una VPC (opcional)
  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids

}