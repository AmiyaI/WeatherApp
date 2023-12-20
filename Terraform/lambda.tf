# Lambda function for weather data processing
resource "aws_lambda_function" "weather_processor" {
  function_name = "WeatherDataProcessor"
  /*
  runtime       = "python3.11"
  handler       = "s3dataingest.lambda_handler"     # Entry point in your Python code
  */
  role = aws_iam_role.lambda_exec_role.arn # IAM role for Lambda execution

  package_type = "Image"
  image_uri    = "004678516606.dkr.ecr.us-east-1.amazonaws.com/my-lambda-repo:s3dataingest"
  timeout      = 30
  /*
  s3_bucket = aws_s3_bucket.lambda_code.bucket
  s3_key    = "s3dataingest.zip"
*/
  vpc_config {
    subnet_ids         = [aws_subnet.private-1.id, aws_subnet.private-2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
      DB_NAME     = var.db_name
      DB_HOST     = aws_db_instance.default.address
      DB_PORT     = var.db_port
    }
  }

  tags = {
    Name = "WeatherDataProcessor"
  }
}


# Lambda function for database initialization
resource "aws_lambda_function" "db_initializer" {
  function_name = "DBInitializer"
  /*
  runtime       = "python3.11"
  handler       = "initialize_db.lambda_handler"    # Entry point in your Python code
  */
  role = aws_iam_role.lambda_exec_role.arn # IAM role for Lambda execution

  package_type = "Image"
  image_uri    = "004678516606.dkr.ecr.us-east-1.amazonaws.com/my-lambda-repo:initialize_db"
  /*
  s3_bucket = aws_s3_bucket.lambda_code.bucket
  s3_key    = "initialize_db.zip"
*/
  vpc_config {
    subnet_ids         = [aws_subnet.private-1.id, aws_subnet.private-2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_NAME     = var.db_name
      DB_USERNAME = var.db_username
      DB_PASSWORD = var.db_password
      DB_HOST     = aws_db_instance.default.address
      DB_PORT     = var.db_port
    }
  }

  tags = {
    Name = "DBInitializer"
  }
}

# Security group for Lambda functions
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lambda Security Group"
  }
}
