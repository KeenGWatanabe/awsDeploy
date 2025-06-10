This folder with submodules APP, backend, secrets, vpc with ECS as the encompassing folder
MAIN branch 
SECRETS branch - secrets manager configuration
BASIC branch - basic configuration

stage: compiling relevant codes for BASIC BRANCH (remove secrets)
---------------------
Run secrets, update iam.tf line 44 for mongo arn

# terraform sequence
$ terraform init
($ terraform apply -target=module.ecr  OR) #ignore this line
$ terraform apply -target=aws_ecr_repository.app

will apply to the following:
module "ecr" {
  source = "./modules/ecr"
  ...
}

# docker and push image to ecr

$ terraform apply 

Navigate to ECS and check status and public DNS url

# deepseek
 SECRETS STATUS, CHECK 
 > pte subnets VPC endpoints,NAT reach Aws Secrets Mgr
 > missing iam permissions secretsmanager:GetSecretValue
 > security grp might block outbound traffic https: port 443 to Aws Secrets Mgr


 image
 255945442255.dkr.ecr.us-east-1.amazonaws.com/ce-grp-4s-app