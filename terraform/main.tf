terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  profile = "qa"
  region  = "us-west-2"
}

resource "aws_ecs_cluster" "scalars_qa" {
  name = "scalars-qa"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_task_definition" "scalars_qa" {
  family = "scalars-app-task"
  # Todo hardcoded arn
  execution_role_arn       = "arn:aws:iam::467432681913:role/ecsTaskExecutionRole"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  cpu                   = 256
  memory                = 512
  container_definitions = file("ecs-task-definitions/scalars-app.json")
}

resource "aws_ecs_service" "scalars_qa" {
  name            = "scalars-app"
  cluster         = aws_ecs_cluster.scalars_qa.id
  desired_count   = 2
  task_definition = aws_ecs_task_definition.scalars_qa.arn
  launch_type     = "FARGATE"

  network_configuration {
    # Todo create subnets and sg's in terraform
    subnets          = ["subnet-759ae85e"]
    security_groups  = ["sg-0a08d5e0a0179e91e"]
    assign_public_ip = true
  }
}
