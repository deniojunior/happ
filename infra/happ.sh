#!/bin/bash

# Script Parameters
# 
# $1: Operation [apply, plan, destroy, show]
# $2: Environment [dev, prod]
# $3: Terraform extra options. Example: -auto-approve
#
# https://www.terraform.io/docs/commands/apply.html
# https://www.terraform.io/docs/commands/destroy.html
# https://www.terraform.io/docs/commands/show.html

OP=$1
ENV=$2
EXTRA_OPS=$3

function setup {
  if [[ -z "${TF_VAR_bucket_name}" ]]; then
    export TF_VAR_bucket_name="happ.$ENV"
  fi

  aws s3 cp s3://$TF_VAR_bucket_name/terraform/terraform.tfstate ./ || \
    printf "\nUnable to download Terraform State file from S3 Bucket.\n\n"
}

function apply {
  setup;
  terraform init;
  terraform apply $EXTRA_OPS -var-file=$VARS || ERROR=1;
  upload_state;

  if [ $ERROR ]; then
    exit 1;
  fi
}

function destroy {
  setup;
  terraform init;
  terraform destroy $EXTRA_OPS -var-file=$VARS || exit 1
}

function plan {
  setup;
  terraform init;
  terraform plan $EXTRA_OPS -var-file=$VARS || exit 1
}

function show {
  setup;
  terraform init;
  terraform show
}

function upload_state {
  aws s3 cp ./terraform.tfstate s3://$TF_VAR_bucket_name/terraform/terraform.tfstate || echo "Failed to upload state!"
}

# Process environment
if [ "$ENV" == "dev" ]; then
  VARS="values/$ENV.tfvars"
elif [ "$ENV" <> "prod" ]; then
  VARS="values/prod.tfvars"
else
  echo "Unknown environment $ENV. Environments available: dev, prod"
  exit 1
fi

# Process operation
if [ "$OP" == "apply" ]; then
  apply
elif [ "$OP" == "destroy" ]; then
  destroy
elif [ "$OP" == "plan" ]; then
  plan
elif [ "$OP" == "show" ]; then
  show
else
  echo "Unknown operation $OP. Operations available: apply, destroy, plan, show"
  exit 1
fi
