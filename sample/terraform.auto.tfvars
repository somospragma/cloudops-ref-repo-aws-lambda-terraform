###############################################################
# Variables Globales
###############################################################


aws_region         = "us-east-1"
profile            = "pra_idp_dev"
environment        = "dev"
client             = "pragma"
project            = "hefesto"
functionality      = "sample"  
application        = "lambda"


common_tags = {
  environment   = "dev"
  project-name  = "Modulos Referencia"
  cost-center   = "-"
  owner         = "cristian.noguera@pragma.com.co"
  area          = "KCCC"
  provisioned   = "terraform"
  datatype      = "interno"
}


handler        = "index.handler"
runtime        = "nodejs18.x"
role_arn       = ""
source_path    = "lambda_function.zip"
memory_size    = 256
timeout        = 10

# Solo si requiere VPC
vpc_subnet_ids         = [""]
vpc_security_group_ids = [""]