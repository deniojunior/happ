region         = "us-east-1"
bucket         = "happ-dj-dev-terraform-state"
key            = "terraform.tfstate"
dynamodb_table = "happ-dj-dev-terraform-state-lock"
profile        = ""
role_arn       = ""
encrypt        = "true"

workspaces {
  name = "cf-infra"
}
