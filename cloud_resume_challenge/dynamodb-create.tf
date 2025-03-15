# CREATE AND BUILD A NEW DYNAMO DB 

resource "aws_dynamodb_table" "terraform_dynamo_db" {
  name         = "TerraformDynamoDB"
  billing_mode = "PAY_PER_REQUEST" # On-demand pricing (no capacity planning needed)

  hash_key = "user_id" # Partition Key

  attribute {
    name = "user_id"
    type = "S" # String
  }

  tags = {
    Name        = "TerraformDynamoDB"
    Environment = "Dev"
    Build       = "Terraform"
  }
}


# Add an item to the DynamoDB table
resource "aws_dynamodb_table_item" "terraform_dynamo_db_item_dd" {
  table_name = aws_dynamodb_table.terraform_dynamo_db.name

  hash_key = "user_id"

  item = jsonencode({
    "user_id"       = { "S" = "rac_portfolio" }
    "visitor_count" = { "N" = "0" }
  })

  depends_on = [aws_dynamodb_table.terraform_dynamo_db]
}