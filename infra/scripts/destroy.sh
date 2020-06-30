#!/bin/bash

#mkdir tmp

terraform init -force-copy
rm -rf .terraform

echo -e "terraform { \nbackend \"local\" {}\n }" > /tmp/backend.tf
yes -yes | terraform init -backend-config=/tmp/backend.tf

echo "$(terraform state list | grep -vE module.cloufront_multiorigin.aws_lambda_function.lambda_edge)" > tmp/resources_to_destroy
echo "terraform destroy -auto-approve $@ \\" > tmp/destroy_script.sh

while read resource; do
  echo "-target='$resource' \\" >> tmp/destroy_script.sh
done < tmp/resources_to_destroy

sed -i '$ s/.$//' tmp/destroy_script.sh
bash tmp/destroy_script.sh;
rm -rf tmp
