resource "aws_dynamodb_table" "app" {
  name     = "sample-sessions"
  hash_key = "name"
  attribute {
    name = "name"
    type = "S"
  }
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
}
