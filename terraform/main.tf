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
  execution_role_arn       = "arn:aws:iam::467432681913:role/ecsTaskExecutionRole"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  cpu                   = 256
  memory                = 512
  container_definitions = file("../ecs-fargate/task-definition.terraform.json")
}

resource "aws_ecs_service" "scalars_qa" {
  name            = "scalars-app-service"
  cluster         = aws_ecs_cluster.scalars_qa.id
  desired_count   = 2
  task_definition = aws_ecs_task_definition.scalars_qa.arn
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.scalars_app.arn
    container_name   = "scalars-app-container"
    container_port   = 8080
  }

  network_configuration {
    # Todo create subnets and sg's in terraform
    subnets          = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
    security_groups  = [aws_default_security_group.default.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_default_vpc" "default" {
 }

resource "aws_lb_target_group" "scalars_app" {
  name     = "scalars-app-lb-tg"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.scalars_qa.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.scalars_app.arn}"
    type             = "forward"
  }
}
# resource "aws_lb_target_group_attachment" "test" {
#   target_group_arn = aws_lb_target_group.scalars_app.arn
#   target_id        = aws_lb.scalars_qa.arn
# }

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-west-2d"
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-west-2b"
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id

  ingress {
    protocol  = "tcp"
    self      = true
    from_port = 80
    to_port   = 80
  }
}

resource "aws_lb" "scalars_qa" {
  name               = "scalars-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_default_security_group.default.id]
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
}
