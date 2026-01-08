# Example: Lambda function using ECR container image
module "lambda_functions" {
  source = "../"
  
  client      = "pragma"
  project     = "genai"
  environment = "dev"
  
  lambda_functions = {
    ml_processor = {
      description = "ML processing function using container image"
      memory_size = 1024
      timeout     = 300
      
      type      = "ecr"
      image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/ml-processor:latest"
      
      environment_variables = {
        MODEL_PATH = "/opt/ml/model"
        LOG_LEVEL  = "INFO"
      }
      
      lambda_iam_role_arn = aws_iam_role.lambda_execution_role.arn
      
      additional_tags = {
        Purpose = "ml-processing"
        Team    = "data-science"
      }
    }
  }
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "pragma-genai-dev-lambda-ml-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}
