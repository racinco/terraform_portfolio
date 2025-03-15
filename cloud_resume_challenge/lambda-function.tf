resource "aws_lambda_function" "lambda-function" {
  filename      = "${path.module}/code.zip"
  function_name = "api-gw-lambda"
  role          = aws_iam_role.iam-role-for-lambda-apg.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
}
