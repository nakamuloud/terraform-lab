data "archive_file" "testfunction_zip" {
  type        = "zip"
  source_dir  = "${path.module}/build"
  output_path = "${path.module}/archive/output.zip"
}

# Lambdaに付与するIAM
resource "aws_iam_role" "testfunction_iam_role" {
  name               = "testfunction_iam_role"
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


resource "aws_lambda_function" "testfunction" {
  function_name = "testfunction"
  handler       = "lambda.handler"
  role          = aws_iam_role.testfunction_iam_role.arn
  runtime       = "nodejs12.x"

  # kms_key_arn = aws_kms_key.lambda_key.arn

  filename         = data.archive_file.testfunction_zip.output_path
  source_code_hash = data.archive_file.testfunction_zip.output_base64sha256

  environment {
    variables = {
      BASE_MESSAGE = "Hello"
    }
  }
}
