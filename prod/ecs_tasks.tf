data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-staging-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode([
	{
	  "name": "frontend",
	  "image": "075730933478.dkr.ecr.ap-northeast-2.amazonaws.com/frontend:latest",
	  "cpu": 256,
	  "memory": 512,
	  "essential": true,
	  "portMappings": [
		{
		  "containerPort": 3000,
		  "hostPort": 3000,
		  "protocol": "tcp"
		}
	  ]
	}
  ])
}
resource "aws_ecs_task_definition" "backend_spring" {
  family                   = "backend_spring"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode([
	{
	  "name": "backend-spring",
	  "image": "075730933478.dkr.ecr.ap-northeast-2.amazonaws.com/backend-spring:latest",
	  "cpu": 256,
	  "memory": 512,
	  "essential": true,
	  "portMappings": [
		{
		  "containerPort": 8080,
		  "hostPort": 8080,
		  "protocol": "tcp"
		}
	  ]
	}
  ])
}