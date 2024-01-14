#DynamoDB table for terraform remote backend state locks
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-run-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
