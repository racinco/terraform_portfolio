# A ROLE NEEDS IS REQUIRED A TRUST POLICY TO ASSUME THE ROLE
# CREATE ASSUMED ROLE FOR lambda : iam-role-for-lambda-apg
data "aws_iam_policy_document" "assume_lambda_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# CREATE ROLE named : iam-role-for-lambda-apg - ATTACH TRUST POLICY: assume_lambda_role
resource "aws_iam_role" "iam-role-for-lambda-apg" {
  name               = "iam-role-for-lambda-apg"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_role.json
}


# ATTACH CLOUD WATCH POLICY FOR ROLE: iam-role-for-lambda-apg
resource "aws_iam_role_policy" "iam-policy" {
  name = "cloudwatch-policy"
  role = aws_iam_role.iam-role-for-lambda-apg.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

# CREATE A DYNAMO DB POLICY FOR: rac_portfolio_visitor_counter
resource "aws_iam_policy" "dynamodb_visitor_policy" {
  name        = "LambdaDynamoDBPolicy"
  description = "Allows Lambda to access DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem" # Optional, add if needed
        ]
        Resource = "${aws_dynamodb_table.terraform_dynamo_db.arn}"
      }
    ]
  })

  depends_on = [aws_dynamodb_table.terraform_dynamo_db]
}

# ATTACH DYNAMO DB POLICY TO ROLE : iam-role-for-lambda-apg
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  policy_arn = aws_iam_policy.dynamodb_visitor_policy.arn
  role       = aws_iam_role.iam-role-for-lambda-apg.name
}
