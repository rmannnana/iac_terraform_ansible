terraform {
  backend "s3" {
    bucket         = "bucketdurequin"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodurequin"
    encrypt        = true
  }
}
