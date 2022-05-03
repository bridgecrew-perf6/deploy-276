
resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name = "frontend"
    container_port = 3000
  }

  network_configuration {
    subnets = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.private.id]
    security_groups = [aws_security_group.ecs-service-default.id]
    assign_public_ip = true
  }

  depends_on = [module.alb, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

resource "aws_ecs_service" "backend-spring" {
  name            = "backend-spring"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.backend_spring.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = module.alb.target_group_arns[1]
    container_name = "backend-spring"
    container_port = 8080
  }

  network_configuration {
    subnets = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.private.id]
    security_groups = [aws_security_group.ecs-service-default.id]
    assign_public_ip = true
  }

  depends_on = [module.alb, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
