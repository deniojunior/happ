backend "s3" {
  region         = "us-east-1"
  bucket         = "happ-deniojunior-dev-terraform-state"
  key            = "terraform.tfstate"
  dynamodb_table = "happ-deniojunior-dev-terraform-state-lock"
  profile        = ""
  role_arn       = ""
  encrypt        = "true"
}
