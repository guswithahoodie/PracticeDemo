# Security Group for the EC2 app instance
resource "aws_security_group" "app_sg" {
  name        = "${var.project}-sg"
  description = "Allow SSH, HTTP, and Django app traffic"
  vpc_id      = var.vpc_id

  # Allow inbound SSH
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound Django (port 8000)
  ingress {
    description = "Allow Django app traffic"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTP (optional — if you later switch to port 80)
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
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

# Output the SG ID (optional but useful)
output "security_group_id" {
  value = aws_security_group.app_sg.id
}
