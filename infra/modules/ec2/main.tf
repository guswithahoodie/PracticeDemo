resource "aws_security_group" "ec2_sg" {
  name        = "${var.project}-ec2-sg"
  vpc_id      = var.vpc_id

  # inbound stays as we configured earlier
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ✅ outbound allow everything
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ec2_eip" {
  domain = "vpc"
  instance = aws_instance.app.id
  tags = {
    Name = "${var.project}-eip"
  }

}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = element(var.public_subnet_ids, 0)
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = templatefile("${path.module}/user_data.tpl", {
    project            = var.project
    ecr_repository_url = var.ecr_repository_url
    image_tag          = var.image_tag
  })
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
  root_block_device {
  volume_size = 10       # at least 10 GB recommended
  volume_type = "gp3"
  }
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
  name = "${var.project}-instance-profile"
  role = var.ec2_role_name
}
