# **🚀 Módulo Terraform para lambda: cloudops-ref-repo-aws-lambda-terraform**

## Descripción:

Este módulo facilita la creación de un lambda con o sin VPC, el cual requiere de los siguientes recursos, los cuales debieron ser previamente creados:

- role_arn: ARN de un rol para ser asociado a la lambda.
- vpc_subnet_ids      : ID de la subnet (En caso de estar asociado a una VPC).
- vpc_security_group_ids : ID del grupo de seguridad (En caso de estar asociado a una VPC).

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo

El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-rds-terraform/
└── sample/
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.auto.tfvars
    └── variables.tf
├── CHANGELOG.md
├── README.md
├── data.tf
├── local.tf
├── main.tf
├── outputs.tf
├── variables.tf
```

- Los archivos principales del módulo (`data.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `locals.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.


## Uso del Módulo:

```hcl
module "lambda_function" {
  source         = "./module/lambda"

  # Variables de nombramiento
  client        = "xxxxx"
  project       = "xxxxx"
  environment   = "xxxxx"
  application   = "xxxxx"
  functionality = "xxxxx"

  # Configuración
  handler        = "xxxxx"
  runtime        = "xxxxx"
  role           = "xxxxx"
  source_path    = "xxxxx"
  memory_size    = "xxxxx"
  timeout        = "xxxxx"

  environment_variables = {"xxxxx","xxxxx"}
  # Asignar valores para asociar la función a una VPC (opcional)
  vpc_subnet_ids         = ["xxxxx"]
  vpc_security_group_ids = ["xxxxx"]
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |

# 📌 Variables

## 🔹 Configuración General

| Nombre          | Tipo   | Descripción                                               | Predeterminado | Obligatorio |
|-----------------|--------|-----------------------------------------------------------|----------------|-------------|
| `client`        | string | Nombre del cliente.                                       | -              | Sí          |
| `environment`   | string | Entorno de despliegue (dev, staging, prod, etc.).         | -              | Sí          |
| `project`       | string | Nombre del proyecto.                                      | -              | Sí          |
| `functionality` | string | Funcionalidad específica dentro del proyecto.             | -              | Sí          |
| `application`   | string | Nombre de la aplicación asociada a la función Lambda.     | -              | Sí          |

## 🔹 Configuración de la Función Lambda

| Nombre                 | Tipo        | Descripción                                                                 | Predeterminado | Obligatorio |
|------------------------|-------------|-----------------------------------------------------------------------------|----------------|-------------|
| `handler`              | string      | Handler de la función Lambda (ej: `index.handler`).                          | -              | Sí          |
| `runtime`              | string      | Runtime de la función Lambda (ej: `nodejs18.x`, `python3.9`, etc.).          | `nodejs18.x`   | No          |
| `role`                 | string      | ARN del rol de ejecución que usará la función Lambda.                        | -              | Sí          |
| `source_path`          | string      | Ruta al archivo ZIP o directorio empaquetado con el código fuente.           | -              | Sí          |
| `environment_variables`| map(string) | Mapa de variables de entorno para la función Lambda.                         | `{}`           | No          |
| `memory_size`          | number      | Memoria asignada a la función Lambda en MB.                                  | `128`          | No          |
| `timeout`              | number      | Tiempo de timeout de la función Lambda en segundos.                          | `3`            | No          |

## 🔹 Configuración de Red (VPC)

| Nombre                  | Tipo        | Descripción                                                                 | Predeterminado | Obligatorio |
|-------------------------|-------------|-----------------------------------------------------------------------------|----------------|-------------|
| `vpc_subnet_ids`        | list(string)| Lista de Subnet IDs para la configuración VPC de la función Lambda.          | `[]`          | No          |
| `vpc_security_group_ids`| list(string)| Lista de Security Group IDs para la configuración VPC de la función Lambda.  | `[]`          | No          |

# 📤 Outputs

| Nombre                 | Descripción                                   |
|------------------------|-----------------------------------------------|
| `lambda_function_arn`  | ARN de la función Lambda creada.              |
| `lambda_function_name` | Nombre de la función Lambda.                  |
| `lambda_invoke_arn`    | ARN de invocación de la función Lambda.       |
