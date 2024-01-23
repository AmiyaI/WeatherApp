# ---------------------------------------------------
# IAM Role and Policy for EC2 Instances
# ---------------------------------------------------

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" }
      },
    ]
  })
}

# Policy for EC2 instances to interact with ECR, S3, DynamoDB, EC2, IAM, and Lambda
resource "aws_iam_policy" "ec2_policy" {
  name = "ec2_policy"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # ECR-related permissions
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories",
          "ecr:ListTagsForResource"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        # DynamoDB-related permissions
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTagsOfResource"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        # S3-related permissions
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketPolicy",
          "s3:GetBucketAcl",
          "s3:GetBucketCORS",
          "s3:GetBucketWebsite",
          "s3:GetBucketVersioning",
          "s3:GetBucketAccelerateConfiguration",
          "s3:GetAccelerateConfiguration",
          "s3:PutAccelerateConfiguration",
          "s3:GetBucketRequestPayment",
          "s3:PutBucketRequestPayment"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        # RDS-related permissions
        Action = [
          "rds:DescribeDBSubnetGroups",
          "rds:ListTagsForResource",
          "rds:DescribeDBInstances"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        # Lambda-related permissions
        Action = [
          "lambda:CreateFunction",
          "lambda:InvokeFunction",
          "lambda:GetFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:DeleteFunction",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:GetPolicy",
          "lambda:ListFunctions",
          "lambda:ListVersionsByFunction"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        # EC2-related permissions
        Action = [
          "ec2:DescribeImages",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribePrefixLists",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        # IAM-related permissions
        Action = [
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:ListRolePolicies",
          "iam:GetPolicyVersion",
          "iam:ListAttachedRolePolicies",
          "iam:GetRolePolicy",
          "iam:GetInstanceProfile"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}


# Attach EC2 policy to EC2 IAM role
resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# Instance Profiles for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion_profile"
  role = aws_iam_role.ec2_role.name
}

# ---------------------------------------------------
# IAM Role and Policies for Lambda Functions
# ---------------------------------------------------

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" }
      },
    ]
  })
}

# Attach AWS managed policy for basic Lambda execution
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy for Lambda function RDS access
resource "aws_iam_role_policy" "lambda_rds_access" {
  name   = "lambda_rds_access"
  role   = aws_iam_role.lambda_exec_role.id
  policy = data.aws_iam_policy_document.lambda_rds_access_policy.json
}

# Policy for Lambda function to operate within VPC
resource "aws_iam_policy" "lambda_vpc_access" {
  name   = "lambda_vpc_access"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_vpc_access_policy.json
}

# Attach VPC access policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_vpc_access_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_vpc_access.arn
}

# Policy for Lambda function ECR access
resource "aws_iam_policy" "lambda_ecr_access" {
  name = "lambda_ecr_access"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Effect   = "Allow",
        Resource = "*" # Specify ECR repository ARN if needed
      },
    ]
  })
}

# Attach ECR access policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_ecr_access_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_ecr_access.arn
}

# Policy for Lambda function to read from S3 bucket
resource "aws_iam_policy" "lambda_s3_access" {
  name = "lambda_s3_access"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::weather-app-data-bucket/*"
      },
    ]
  })
}

# Attach S3 access policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_s3_access_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

# ---------------------------------------------------
# Lambda Permissions
# ---------------------------------------------------

# Permission for S3 to trigger Lambda function
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.weather_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::weather-app-data-bucket"
}


# ---------------------------------------------------
# IAM Policy for Lambda RDS Access
# ---------------------------------------------------

data "aws_iam_policy_document" "lambda_rds_access_policy" {
  statement {
    actions   = ["rds-db:connect"]
    resources = [aws_db_instance.default.arn]
  }
}

# ---------------------------------------------------
# IAM Policy Document for Lambda VPC Access
# ---------------------------------------------------

data "aws_iam_policy_document" "lambda_vpc_access_policy" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
}


# ---------------------------------------------------
# IAM Policy Document for S3 Remote Backend 
# ---------------------------------------------------
resource "aws_iam_policy" "terraform_backend_access" {
  name        = "TerraformBackendAccess"
  path        = "/"
  description = "Policy to allow Terraform to access S3 bucket and DynamoDB table for state management"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:ListBucket"],
        Effect   = "Allow",
        Resource = ["arn:aws:s3:::my-terraform-state-bucket-weatherapp"]
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Effect   = "Allow",
        Resource = ["arn:aws:s3:::my-terraform-state-bucket-weatherapp/state/*"]
      },
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Effect   = "Allow",
        Resource = ["arn:aws:dynamodb:*:*:table/terraform-up-and-run-locks"]
      }
    ]
  })
}
