resource "aws_ecr_repository" "webdav_image_repo" {
  name = var.SUBDOMAIN
  force_delete = true
}