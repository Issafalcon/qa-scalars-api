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
  family                = "scalars-app-task"
  container_definitions = file("ecs-task-definitions/scalars-app.json")
}

resource "aws_ecs_service" "scalars_qa" {
  name            = "scalars-app"
  cluster         = aws_ecs_cluster.scalars_qa.id
  desired_count   = 2
  task_definition = aws_ecs_task_definition.scalars_qa.arn
}
