resource "aws_ecs_cluster" "this" {
  name = "${var.project}-${var.env}-cluster"
}

# Log group
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.project}-${var.env}"
  retention_in_days = 7
}

# Task definition (Fargate)
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-${var.env}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "athena-api"
      image = "${aws_ecr_repository.app.repository_url}:latest"  # update with proper tag
      essential = true
      portMappings = [{ containerPort = 8000, hostPort = 8000, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "athena"
        }
      }
      environment = [
        { name = "DB_HOST", value = aws_db_instance.postgres.address },
        { name = "DB_PORT", value = "5432" },
        { name = "DB_NAME", value = aws_db_instance.postgres.name },
        { name = "DB_USER", value = "athena" },
        { name = "DB_PASSWORD", value = random_password.db_password.result },
        { name = "APP_ENV", value = "prod" }
      ]
    }
  ])
}

# Security group for ECS tasks (allow from ALB)
resource "aws_security_group" "ecs_sg" {
  name        = "${var.project}-${var.env}-ecs-sg"
  description = "Allow ALB to reach ECS tasks"
  vpc_id      = aws_vpc.this.id
  ingress {
    description = "From ALB"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS service (attached to ALB target group created later)
resource "aws_ecs_service" "this" {
  name            = "${var.project}-${var.env}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "athena-api"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.front]
}
