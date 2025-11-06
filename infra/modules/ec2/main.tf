resource "aws_security_group" "ec2_sg" {
  name   = "${var.project}-${var.env}-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH (your IP only)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-${var.env}-sg" }
}

resource "aws_eip" "ec2_eip" {
  domain = "vpc"
  instance = aws_instance.app.id
  tags = { Name = "${var.project}-${var.env}-eip" }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = element(var.public_subnet_ids, 0)
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data              = templatefile("${path.module}/user_data.tpl", {
    git_repo   = var.git_repo
    git_branch = var.git_branch
    project    = var.project
  })
  tags = { Name = "${var.project}-${var.env}-ec2" }
}

data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-${var.env}-instance-profile"
  role = var.ec2_role_name
}
