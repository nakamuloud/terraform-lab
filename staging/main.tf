provider "aws" {
  version = "v3.13.0"
}
provider "archive" {
  version = " 2.0.0"
}

module "apigateway" {
  source       = "../module/api_gateway"
  prefix       = "hoge"
  project_name = "test"
  stage_name   = "staging"
}


module "testfunction" {
  source = "../module/lambda/testfunction"
}
