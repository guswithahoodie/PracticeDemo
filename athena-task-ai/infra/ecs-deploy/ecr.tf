resource "aws_ecr_repository" "app" {
  name = "${var.project}-${var.env}"
  image_tag_mutability = "MUTABLE"
  tags = { Name = "${var.project}-${var.env}-ecr" }
}
