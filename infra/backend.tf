terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "happ-hm-terraform-state"
    key            = "terraform.tfstate"
    dynamodb_table = "happ-hm-terraform-state-lock"
    profile        = ""
    role_arn       = ""
    encrypt        = "true"
  }
}
