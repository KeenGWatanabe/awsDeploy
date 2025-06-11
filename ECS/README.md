change main.tf ln 95 - valueFrom =""
change iam.tf ln84 - resource = [""]
change iam.tf ln138 - resource = [""]
# so is the prod.tfvars and dev.tfvars for have separate tfstate files when terraforming?
workspace

terraform pull origin main
$ terraform init
$ terraform workspace new secrets #do once only
$ terraform workspace select secrets
$ terraform workspace list #just to check workspace at
$ terraform plan -var-file="secrets.tfvars"
$ terraform apply -var-file="secrets.tfvars"
----------------------------------------------------

git add .
git commit -m "msg"  
git push origin -u main


# cli force deployment
$ aws ecs update-service --cluster <cluster-name> --service <service-name> --force-new-deployment

aws ecs update-service --cluster ce-grp-4t-app-cluster --service ce-grp-4t-app-service-f48ddcab --force-new-deployment

aws ecs update-service --cluster ce-grp-4x-app-cluster --service ce-grp-4x-app-service-1430dc37 --force-new-deployment

ecs_cluster_name = "secrets-app-cluster"
service_url = "secrets72bd4159-app-lb-1709309573.us-east-1.elb.amazonaws.com"