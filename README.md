Run secrets, update iam.tf line 44 for mongo arn

# terraform sequence
$ terraform init
$ terraform apply -target=module.ecr  OR
$ terraform apply -target=aws_ecr_repository.app

will apply to the following:
module "ecr" {
  source = "./modules/ecr"
  ...
}

# docker and push image to ecr

$ terraform apply 
