resource "aws_db_subnet_group" "rds_subnets" {
  name       = "${var.project}-${var.env}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = "${var.project}-${var.env}-db-subnet-group" }
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.project}-${var.env}-postgres"
  engine                 = "postgres"
  engine_version         = "15.7"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = "demo_project"
  username               = "demo_project"
  password               = random_password.db_password.result
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  tags                   = { Name = "${var.project}-${var.env}-postgres" }
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!@#"
}
