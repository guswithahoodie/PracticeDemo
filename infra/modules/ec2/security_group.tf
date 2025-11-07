resource "aws_security_group" "app_sg" {
  name        = "${var.project}-sg"
  description = "Allow inbound HTTP (8000) and all outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP for Django app"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-sg"
  }
}
