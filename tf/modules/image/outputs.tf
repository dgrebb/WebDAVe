output "webdav_server_image" {
  value = aws_ecr_repository.webdav_image_repo.repository_url
  sensitive = true
}