# Creating an ECR repository for Lambda functions
resource "aws_ecr_repository" "lambda_repository" {
  name                 = "my-lambda-repo"
  image_tag_mutability = "MUTABLE" # Allows image tags to be overwritten
}
