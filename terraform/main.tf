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

