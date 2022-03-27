resource "aws_ecs_service" "default" {
  name            = "default"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
	container_name = "httpservice"
	container_port = 80
  }

  network_configuration {
	subnets = [aws_subnet.public1.id]
	security_groups = [aws_security_group.ecs-service-default.id]
	assign_public_ip = true
  }

  depends_on = [module.alb, aws_iam_role_policy_attachment.ecs_task_execution_role]
}