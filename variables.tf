###########################################
#            Lambda Unified Module        #
###########################################

variable "lambda_functions" {
  description = "Map of Lambda functions to create"
  type = map(object({
    # Function Configuration
    description = optional(string, "Lambda function")
    handler     = string
    runtime     = string
    memory_size = optional(number, 128)
    timeout     = optional(number, 30)
    
    # Source Configuration - Tipo: directory o s3
    type = string
    
    # Para type = "directory"
    source_path = optional(string, "")
    
    # Para type = "s3" 
    s3_bucket        = optional(string, "")
    s3_key           = optional(string, "")
    source_code_hash = optional(string, "")
    
    # Environment Variables
    environment_variables = optional(map(string), {})
    
    # Layers Configuration - ARNs de layers externos
    layer_arns = optional(list(string), [])
    
    # Permissions Configuration
    permissions = optional(list(object({
      principal    = string
      action       = string
      statement_id = string
      source_arn   = optional(string)
    })), [])
    
    # External Dependencies
    lambda_iam_role_arn = string
    lambda_kms_key_arn  = optional(string)
    
    # VPC Configuration
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
    }))
    
    # CloudWatch Configuration
    log_retention_days = optional(number, 14)
    
    # Etiquetas específicas de la función Lambda
    additional_tags = optional(map(string), {})
  }))
  
  validation {
    condition = alltrue([
      for k, v in var.lambda_functions : contains(["directory", "s3"], v.type)
    ])
    error_message = "Lambda function type must be one of: directory, s3"
  }
  
  validation {
    condition = alltrue([
      for k, v in var.lambda_functions : v.memory_size >= 128 && v.memory_size <= 10240
    ])
    error_message = "Memory size must be between 128 and 10240 MB"
  }
  
  validation {
    condition = alltrue([
      for k, v in var.lambda_functions : v.timeout >= 1 && v.timeout <= 900
    ])
    error_message = "Timeout must be between 1 and 900 seconds (15 minutes)"
  }
    validation {
      condition = alltrue([
        for k, v in var.lambda_functions : contains([
          1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
        ], v.log_retention_days)
      ])
      error_message = "Log retention days must be one of the valid CloudWatch values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653"
    }
}

# Compile_layers ahora se maneja por layer individual en la configuración de cada layer

###########################################
#       Sistema de Etiquetado             #
###########################################

variable "client" {
  description = "Client name for resource naming and tagging"
  type        = string
}

variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name for resource naming and tagging"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "pdn", "prod"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn. prod."
  }
}

###########################################
#       CloudWatch Configuration          #
###########################################

# variable "log_retention_days" {
#   description = "CloudWatch log retention in days"
#   type        = number
#   default     = 14
  
#   validation {
#     condition = contains([
#       1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
#     ], var.log_retention_days)
#     error_message = "Log retention days must be one of the valid CloudWatch values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653"
#   }
# }