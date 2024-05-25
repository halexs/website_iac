# data "aws_iam_policy" "lambda" {
#   arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# data "aws_iam_policy_document" "lambda_cloudwatch_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "lambda_cloudwatch" {
#   name               = "cloudwatch_role"
#   assume_role_policy = data.aws_iam_policy_document.lambda_cloudwatch_role.json
# }

# resource "aws_iam_role_policy_attachment" "lambda_cloudwatch" {
#   role       = aws_iam_role.lambda_cloudwatch.name
#   policy_arn = data.aws_iam_policy.lambda.arn
# }

# resource "aws_iam_role" "api_gateway_cloudwatch" {
#   name = "codepipeline-codebuild-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codebuild.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_api_gateway_stage" "main" {
#   stage_name = "Test_Stage"

#   deployment_id = aws_api_gateway_deployment.main.id
#   rest_api_id   = aws_api_gateway_rest_api.main.id

#   depends_on = [aws_cloudwatch_log_group.api_gateway]
# }

# resource "aws_cloudwatch_log_group" "api_gateway" {
#   name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.main.id}/Test_Stage"
#   retention_in_days = 7
#   # ... potentially other configuration ...
# }


# resource "aws_api_gateway_method_settings" "example" {
#   rest_api_id = aws_api_gateway_rest_api.main.id
#   stage_name  = aws_api_gateway_stage.main.stage_name
#   method_path = "*/*"

#   settings {
#     metrics_enabled = true
#     logging_level   = "INFO"
#   }
# }