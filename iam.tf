resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Permissions for CloudWatch
resource "aws_iam_role_policy" "ecs_logging" {
  name   = "ecs-task-execution-logs"
  role   = aws_iam_role.ecs_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:us-east-1:255945442255:log-group:/ecs/${var.name_prefix}-app:*"
      }
    ]
  })
}


# Reference the secret ARN from the Secrets Repo
data "aws_secretsmanager_secret" "mongo_uri" {
  arn = "arn:aws:secretsmanager:us-east-1:255945442255:secret:prod/mongodb_uri-5di2sd"
}

# Permissions for Secrets Mgr
resource "aws_iam_role_policy" "secrets_access" {
  role   = aws_iam_role.ecs_execution_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["secretsmanager:GetSecretValue"],
      Resource = [data.aws_secretsmanager_secret.mongo_uri.arn]
    }]
  })
}
