variable "client" {
  type = string
}
variable "environment" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "profile" {
  type = string
}
variable "common_tags" {
    type = map(string)
    description = "Tags comunes aplicadas a los recursos"
}
variable "project" {
  type = string  
}
variable "functionality" {
  type = string  
}
variable "application" {
  type = string  
}



########### Varibales Lambda



variable "handler" {
  description = "Handler de la función Lambda (ej: index.handler)"
  type        = string
}

variable "runtime" {
  description = "Runtime de la función Lambda (ej: nodejs18.x, python3.9, etc.)"
  type        = string
  default     = "nodejs18.x"
}

variable "role_arn" {
  description = "ARN del rol de ejecución que usará la función Lambda"
  type        = string
}

variable "source_path" {
  description = "Ruta al archivo ZIP o directorio empaquetado con el código fuente de la función Lambda"
  type        = string
}

variable "environment_variables" {
  description = "Mapa de variables de entorno para la función Lambda"
  type        = map(string)
  default     = {}
}

variable "memory_size" {
  description = "Memoria asignada a la función Lambda en MB"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Tiempo de timeout de la función Lambda en segundos"
  type        = number
  default     = 3
}

variable "vpc_subnet_ids" {
  description = "Lista de Subnet IDs para la configuración VPC de la función Lambda. Déjalo vacío si no se requiere."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Lista de Security Group IDs para la configuración VPC de la función Lambda. Déjalo vacío si no se requiere."
  type        = list(string)
  default     = []
}


