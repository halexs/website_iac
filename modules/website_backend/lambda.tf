locals {
  python_file = "get_location"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "kaelnomads-getLocation-role-udgzobzp"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  managed_policy_arns = [
    "arn:aws:iam::043038001148:policy/service-role/AWSLambdaBasicExecutionRole-2ace4102-d739-4121-ba89-cd104b087c66",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]
  path = "/service-role/"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/${local.python_file}.py"
  output_path = "${path.module}/lambda_function_payload.zip"
}

resource "aws_lambda_function" "main" {
  function_name = "kaelnomads-getLocation_tf"
  filename      = "${path.module}/lambda_function_payload.zip"
  role          = aws_iam_role.lambda.arn
  handler       = "${local.python_file}.lambda_handler"
  # publish       = true

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"
}

# data "archive_file" "lambda" {
#   type        = "zip"
#   source_file = "${path.module}/test.js"
#   output_path = "${path.module}/lambda_function_payload.zip"
# }

# resource "aws_lambda_function" "main" {
#   function_name = "kaelnomads-getLocation_tf"
#   filename      = "${path.module}/lambda_function_payload.zip"
#   role          = aws_iam_role.lambda.arn
#   handler       = "test.handler"
#   # publish       = true

#   source_code_hash = data.archive_file.lambda.output_base64sha256

#   runtime = "nodejs20.x"
# }

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
  # source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*"
}