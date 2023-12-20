# S3 Bucket Configuration for Weather Data
resource "aws_s3_bucket" "data_bucket" {
  bucket = "weather-app-data-bucket" # Replace with your unique bucket name

  tags = {
    Name = "WeatherDataBucket"
  }
}

# Enable Versioning for the S3 Bucket
resource "aws_s3_bucket_versioning" "enable_versioning" {
  bucket = aws_s3_bucket.data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-Side Encryption Configuration for the S3 Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_configuration" {
  bucket = aws_s3_bucket.data_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public access block settings for the bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Notification Configuration for Lambda Function
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.weather_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}



/* Not in use - used docker images with ecr instead of using zip files for lambda functions
resource "aws_s3_bucket" "lambda_code" {
  bucket = "weather-app-lambda-code-bucket"

  tags = {
    Name        = "Weather App Lambda Code Bucket"
    Environment = "Production"
  }
}
*/
