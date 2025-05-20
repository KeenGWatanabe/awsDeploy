# terraform sequence
$ terraform init
$ terraform apply -target=module.ecr

will apply to the following:
module "ecr" {
  source = "./modules/ecr"
  ...
}

# docker and push image to ecr

$ terraform apply 
