# tf-aws-infra

Terraform infra for assessment:
- VPC (public/private subnets)
- Key pair
- IAM instance profile (EC2 -> S3 GetObject & PutObject)
- EBS volume (attached to EC2)
- EBS snapshots via DLM lifecycle policy
- EC2 (app) t3.medium + EBS
- Bastion host t2.micro
- Security groups: restrictive by default
- Remote state stored in S3 (bootstrap creates bucket & DynamoDB)

## Quick steps

1. Bootstrap backend (creates S3 bucket and DynamoDB table):
cd bootstrap
terraform init
terraform apply -var="prefix=your-unique-prefix" -auto-approve

Note the `backend_bucket` and `dynamodb_table` outputs.

2. Configure backend for root:
Create `backend.hcl` in root:


bucket = "<output-backend_bucket-from-bootstrap>"
key = "tfstate/tf-aws-infra.tfstate"
region = "us-east-1" # or chosen region
encrypt = true
dynamodb_table = "<output-dynamodb_table>"

Then run:


terraform init -backend-config=backend.hcl
terraform apply -auto-approve


3. Change variables in `variables.tf` as needed.

## Notes

- Each module is independent.
- Bastion host is used to SSH into private EC2.
- Tag EBS volumes with `backup=true` to be covered by DLM policy.