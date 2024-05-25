
# The code is weird with uploaded code.
# resource "aws_lambda_function" "import" {
#   function_name = "kaelnomads-getLocation"
#   filename      = "${path.module}/lambda_function_payload.zip"
#   role          = aws_iam_role.lambda.arn
#   handler       = "lambda_function.lambda_handler"
#   # publish       = true

#   source_code_hash = "dzFrEkkjCTrymT3Ph0KJ7IwEvW23ZKC8Sn2+wlhwcs4="

#   runtime = "python3.9"
# }

resource "aws_api_gateway_rest_api" "import" {
  #   body = jsonencode({
  #     openapi = "3.0.1"
  #     info = {
  #       title   = "example"
  #       version = "1.0"
  #     }
  #     paths = {
  #       "/path1" = {
  #         get = {
  #           x-amazon-apigateway-integration = {
  #             httpMethod           = "GET"
  #             payloadFormatVersion = "1.0"
  #             type                 = "HTTP_PROXY"
  #             uri                  = "https://ip-ranges.amazonaws.com/ip-ranges.json"
  #           }
  #         }
  #       }
  #     }
  #   })

  # put_rest_api_mode = "merge"

  name = "kaelnomads"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}