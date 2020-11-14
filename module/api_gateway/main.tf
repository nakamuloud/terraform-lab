variable "prefix" {}
data "aws_region" "current" {}
variable "project_name" {}
variable "stage_name" {}
variable "testfunction_arn" {}
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
    get_lambda_function_arn = var.testfunction_arn
    set_lambda_function_arn = data.aws_lambda_alias.set_function_prod.arn
  }
}


# Lambdaに付与するIAM
resource "aws_iam_role" "api" {
  name               = "api"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "api" {
  name       = "api_iam_policy_attachment"
  roles      = [aws_iam_role.api.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


resource "aws_api_gateway_rest_api" "api" {
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


resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name
  depends_on  = [aws_api_gateway_rest_api.api]
}
