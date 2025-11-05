# Security Group for RDS (Postgres)
resource "aws_security_group" "rds_sg" {
  name        = "demo_project-rds-sg"
  description = "Allow ECS access to Postgres"
  vpc_id      = aws_vpc.my_aws_vpc.id

  ingress {
    description     = "Postgres access from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo_project-rds-sg"
  }
}

resource "aws_security_group" "ecs_service_sg" {
  name        = "demo_project-ecs-sg"
  description = "Allow ECS tasks to reach external services"
  vpc_id      = aws_vpc.my_aws_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo_project-ecs-sg"
  }
}
