terraform {
  backend "s3" {
    bucket         = "mon-terraform-state-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
