# Módulo Terraform: lambda

## Descripción

Este módulo gestiona la creación y configuración de funciones AWS Lambda con soporte para múltiples tipos de fuente de código. Proporciona una interfaz unificada para desplegar funciones Lambda desde directorios locales o desde objetos S3, con gestión automática de logs, permisos y configuraciones avanzadas.

Para más detalles sobre los cambios y versiones, consulte el [CHANGELOG.md](./CHANGELOG.md).

## ✅ Características

- ✅ Soporte para múltiples tipos de fuente (directory, s3)
- ✅ Compresión automática de código fuente
- ✅ Gestión automática de CloudWatch Log Groups
- ✅ Configuración flexible de permisos y políticas
- ✅ Soporte para variables de entorno
- ✅ Configuración VPC opcional
- ✅ Integración con Lambda Layers externos
- ✅ Cifrado KMS para variables de entorno
- ✅ Sistema de etiquetado consistente

## Estructura del Módulo

```
lambda/
├── README.md           # Este archivo
├── CHANGELOG.md        # Historial de cambios
├── main.tf            # Recursos principales
├── variables.tf       # Variables de entrada
├── outputs.tf         # Valores de salida
├── locals.tf          # Valores locales
└── providers.tf       # Configuración de proveedores
```

## Implementación y Configuración

### Requisitos Técnicos

- **Terraform**: >= 1.0
- **Provider AWS**: >= 4.31.0
- **Provider Archive**: >= 2.0

### Provider Configuration

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.31.0"
      configuration_aliases = [aws.project]
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">=2.0"
    }
  }
}
```

### Convenciones de Nomenclatura

Los recursos creados siguen la convención:
```
{client}-{project}-{environment}-{function-name}
```

Ejemplo: `pragma-genai-dev-lambda-api-handler`

### Estrategia de Etiquetado

El módulo aplica tags automáticamente siguiendo la estrategia corporativa:
- **Name**: Nombre de la función generado
- Tags adicionales configurables por función

### Recursos Gestionados

- `aws_lambda_function`: Funciones Lambda
- `aws_cloudwatch_log_group`: Grupos de logs CloudWatch
- `aws_lambda_permission`: Permisos de invocación
- `data.archive_file`: Compresión automática de código fuente

### Parámetros de Entrada

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_lambda_functions"></a> [lambda_functions](#input_lambda_functions) | Mapa de configuración de funciones Lambda | `map(object)` | `{}` | yes |
| <a name="input_client"></a> [client](#input_client) | Nombre del cliente para etiquetado | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input_project) | Nombre del proyecto para etiquetado | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input_environment) | Entorno de despliegue (dev, qa, pdn) | `string` | n/a | yes |
| <a name="input_log_retention_days"></a> [log_retention_days](#input_log_retention_days) | Días de retención para logs CloudWatch | `number` | `14` | no |

### Estructura de Configuración

```hcl
lambda_functions = {
  function-name = {
    name        = "complete-function-name"
    description = "Descripción de la función"
    handler     = "index.handler"
    runtime     = "nodejs22.x"
    memory_size = 128
    timeout     = 30
    
    # Tipo de fuente
    type = "directory"  # directory, s3
    
    # Para type = "directory"
    source_path = "./src/lambda"
    
    # Para type = "s3"
    s3_bucket        = "bucket-name"
    s3_key           = "path/to/function.zip"
    source_code_hash = "sha256-hash"
    
    # Variables de entorno
    environment_variables = {
      NODE_ENV = "production"
      API_URL  = "https://api.example.com"
    }
    
    # Layers externos
    layer_arns = [
      "arn:aws:lambda:region:account:layer:layer-name:version"
    ]
    
    # Permisos
    permissions = [
      {
        principal    = "apigateway.amazonaws.com"
        action       = "lambda:InvokeFunction"
        statement_id = "apiGatewayInvoke"
        source_arn   = "arn:aws:execute-api:region:account:api-id/*"
      }
    ]
    
    # Configuración de seguridad
    lambda_iam_role_arn = "arn:aws:iam::account:role/lambda-role"
    lambda_kms_key_arn  = "arn:aws:kms:region:account:key/key-id"
    
    # Configuración VPC (opcional)
    vpc_config = {
      subnet_ids         = ["subnet-12345", "subnet-67890"]
      security_group_ids = ["sg-12345"]
    }
    
    # Tags adicionales
    additional_tags = {
      Purpose = "api-handler"
      Team    = "backend"
    }
  }
}
```

### Valores de Salida

| Name | Description |
|------|-------------|
| <a name="output_lambda_function_arns"></a> [lambda_function_arns](#output_lambda_function_arns) | ARNs de todas las funciones Lambda creadas |
| <a name="output_lambda_function_names"></a> [lambda_function_names](#output_lambda_function_names) | Nombres de todas las funciones Lambda creadas |
| <a name="output_lambda_function_invoke_arns"></a> [lambda_function_invoke_arns](#output_lambda_function_invoke_arns) | ARNs de invocación para API Gateway |
| <a name="output_log_group_names"></a> [log_group_names](#output_log_group_names) | Nombres de los grupos de logs CloudWatch |

### Ejemplos de Uso

#### Ejemplo 1: Función Simple desde Directorio

```hcl
module "lambda_functions" {
  source = "./modules/lambda"
  
  client      = "pragma"
  project     = "genai"
  environment = "dev"
  
  lambda_functions = {
    hello_world = {
      name        = "pragma-genai-dev-hello-world"
      description = "Hello World function"
      handler     = "index.handler"
      runtime     = "nodejs22.x"
      type        = "directory"
      source_path = "./src/hello-world"
      
      lambda_iam_role_arn = aws_iam_role.lambda_role.arn
      permissions = []
      additional_tags = {
        Purpose = "demo"
      }
    }
  }
}
```

#### Ejemplo 2: Función con Layers y Permisos

```hcl
module "lambda_functions" {
  source = "./modules/lambda"
  
  client      = "pragma"
  project     = "genai"
  environment = "dev"
  
  lambda_functions = {
    api_handler = {
      name        = "pragma-genai-dev-api-handler"
      description = "API Gateway handler"
      handler     = "app.handler"
      runtime     = "nodejs22.x"
      memory_size = 256
      timeout     = 30
      
      type        = "directory"
      source_path = "./src/api"
      
      layer_arns = [
        module.lambda_layers.layer_arns["aws-layer"],
        module.lambda_layers.layer_arns["utils-layer"]
      ]
      
      environment_variables = {
        NODE_ENV = "production"
        API_KEY  = var.api_key
      }
      
      permissions = [
        {
          principal    = "apigateway.amazonaws.com"
          action       = "lambda:InvokeFunction"
          statement_id = "apiGatewayInvoke"
        }
      ]
      
      lambda_iam_role_arn = aws_iam_role.api_lambda_role.arn
      additional_tags = {
        Purpose = "api-gateway"
        Team    = "backend"
      }
    }
  }
}
```

## Escenarios de Uso Comunes

### 1. API Backend
- Funciones para endpoints REST
- Integración con API Gateway
- Manejo de autenticación y autorización

### 2. Procesamiento de Eventos
- Respuesta a eventos S3, DynamoDB, SQS
- Procesamiento asíncrono
- Transformación de datos

### 3. Tareas Programadas
- Funciones cron con EventBridge
- Mantenimiento automático
- Reportes periódicos

### 4. Microservicios
- Funciones especializadas por dominio
- Comunicación entre servicios
- Escalabilidad independiente

## Consideraciones Operativas

### Performance
- Configuración óptima de memoria y timeout
- Uso de layers para reducir cold starts
- Reutilización de conexiones

### Monitoreo
- Logs automáticos en CloudWatch
- Métricas de performance
- Alertas de errores

### Seguridad
- Roles IAM con permisos mínimos
- Cifrado de variables de entorno
- Configuración VPC para aislamiento

## Seguridad y Cumplimiento

### Controles de Seguridad
- Validación de configuraciones de entrada
- Roles IAM específicos por función
- Cifrado en tránsito y en reposo

### Cumplimiento
- Nomenclatura estándar corporativa
- Trazabilidad completa de recursos
- Auditoría de cambios y accesos

## Observaciones

- **Tamaño del Código**: Límite de 50MB para archivos ZIP (250MB sin comprimir)
- **Timeout**: Máximo 15 minutos por ejecución
- **Memoria**: Rango de 128MB a 10,240MB
- **Concurrent Executions**: Límites por región aplicables
- **VPC**: Configuración VPC puede aumentar cold start times