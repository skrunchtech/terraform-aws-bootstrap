#!/bin/bash
# Create terraform remote state bucket and dynamodb table for state lock
########################################################################

if [[ -z "${STATE_BUCKET}" ]]; then
  echo "The S3 bucket name for saving terraform state is required, please run again after setting 'STATE_BUCKET' environment variable"
  exit 1
fi

aws s3api list-buckets &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "ERROR WITH AWS CREDENTIALS"
    echo "Please verify your default profile AWS credentials or set an AWS_PROFILE env variable before running this script" 
    exit 1
fi

state_bucket=${STATE_BUCKET}
echo "#######################################################"
echo "Creating the backend bucket"
echo "#######################################################"
aws s3api create-bucket --bucket $state_bucket --region us-east-1
aws s3api put-bucket-versioning --bucket $state_bucket --versioning-configuration Status=Enabled
aws s3api get-bucket-versioning --bucket $state_bucket
############
echo "#######################################################"
echo "Creating the Dyanmodb Lock Table"
echo "#######################################################"
aws dynamodb describe-table --table-name tf_lock
if [ $? -ne 0 ]; then
    aws dynamodb create-table  \
    --region us-east-1 \
    --table-name tf_lock  \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=20,WriteCapacityUnits=20
fi