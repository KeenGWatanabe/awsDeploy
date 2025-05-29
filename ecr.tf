
# # this can terraform -target=aws_ecr_respository.app prior to pushing Docker image
# resource "aws_ecr_repository" "app" {
#   name                 = "${var.name_prefix}-app"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

# resource "aws_iam_role_policy_attachment" "ecr_read" {
#   role       = aws_iam_role.ecs_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# resource "aws_iam_role_policy" "ecr_auth" {
#   role   = aws_iam_role.ecs_execution_role.name
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action   = ["ecr:GetAuthorizationToken"],
#       Effect   = "Allow",
#       Resource = "*"
#     }]
#   })
# }