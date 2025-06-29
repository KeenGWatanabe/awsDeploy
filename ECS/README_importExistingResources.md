# use arn for target_grp ########################
terraform import aws_lb_target_group.app arn:aws:elasticloadbalancing:us-east-1:015519021252:targetgroup/secrets-app-tg/fbfd0b0e8bcac037

# use id for security_grp ########################
terraform import aws_security_group.alb sg-038178a1aa4aab254

terraform import aws_security_group.vpc_endpoint sg-0f5a753b30a52d115  

# use role_name for iam_role ######################
terraform import aws_iam_role.ecs_task_execution_role ecs-task-execution-role-secrets

terraform import aws_iam_role.ecs_xray_task_role ecs-xray-taskrole-secrets

# use name for ECR repo #####################
terraform import aws_ecr_repository.app secrets-app

# use log_group_names for CloudWatch log groups ############# (powershell)
terraform import aws_cloudwatch_log_group.ecs_logs "/ecs/secrets-app-service"

terraform import aws_cloudwatch_log_group.xray "/ecs/secrets-xray-daemon"