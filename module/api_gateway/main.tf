variable "prefix" {}
data "aws_region" "current" {}
variable "project_name" {}
variable "stage_name" {}
################################################################################
# Lambda                                                                       #
################################################################################

data "aws_lambda_alias" "get_function_prod" {
  function_name = "ApigwTest-GetName-LambdaFunction"
  name          = "Prod"
}

data "aws_lambda_alias" "set_function_prod" {
  function_name = "ApigwTest-SetName-LambdaFunction"
  name          = "Prod"
}

data "template_file" "swagger" {
  template = file("${path.module}/swagger.yml")

  vars = {
    title                   = var.prefix
    aws_region_name         = data.aws_region.current.name
    get_lambda_function_arn = data.aws_lambda_alias.get_function_prod.arn
    set_lambda_function_arn = data.aws_lambda_alias.set_function_prod.arn
  }
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name        = var.prefix
  description = "APIGateway Test for Terraform"
  body        = data.template_file.swagger.rendered
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = {
    Name = var.project_name
  }
}

resource "aws_api_gateway_stage" "default" {
  stage_name    = var.stage_name
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.default.id
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = var.stage_name
}
