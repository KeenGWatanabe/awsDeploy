terraform {
  backend "s3" {
    bucket = "${var.name_prefix}.tfstate-backend.com"
    key = "secretsecs/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-locks"  # Critical for locking
  }
}



provider "aws" {
  region = "us-east-1"
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = "${var.name_prefix}-app-cluster"
  cluster_configuration = {
      execute_command_configuration = {
        logging = "OVERRIDE"
        log_configuration = {
          cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
        }
      }
    }
  # Capacity provider - Fargate
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  tags = {
    Environment = "production"
    Application = "${var.name_prefix}-nodejs-app"
  }
}
# Create CLoudWatch Log Group for taskDef reference
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.name_prefix}-app"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name_prefix}-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512 #1024 
  memory                   = 1024 #2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "${var.name_prefix}-app"
    image     = "${aws_ecr_repository.app.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
    }],
    secrets = [{
      name      = "MONGODB_URI",  # Populates process.env.MONGODB_URI
      valueFrom = aws_secretsmanager_secret.mongo_uri.arn
    }]
    # environment = [
    #   {
    #     name  = "MONGODB_ATLAS_URI"
    #     value = var.MONGO_URI
    #   }
    # ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.name_prefix}-app"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# unique ID for certain resources
resource "random_id" "suffix" {
  byte_length = 4
}
resource "aws_ecs_service" "app" {
  name            = "${var.name_prefix}-app-service-${random_id.suffix.hex}"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids # aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "${var.name_prefix}-app"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.app]
  
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecr_repository" "app" {
  name                 = "${var.name_prefix}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
