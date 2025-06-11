This folder with submodules APP, backend, secrets, vpc with ECS as the encompassing folder
MAIN branch 
SECRETS branch - secrets manager configuration
BASIC branch - basic configuration


---------------------
# SEQUENCE RUN
file              |    amendments          |      outputs
backend           |    name_prefix         |      bucket name, dynamodb name
vpc               |    name_prefix         |  vpc id, subnets id, endpoint id
secrets mgr       |    name_prefix         |  secrets_arn, secrets_name 
ecs               |    main.tf ln95        |
                       iam.tf ln84         |
                       iam.tf ln138        | 
                       del roles if exists |

app               | connect.js-secrets_name          
                  | workflows-ECR name, Container name