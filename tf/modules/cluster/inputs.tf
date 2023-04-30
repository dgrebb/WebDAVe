variable "SUBDOMAIN" {
  sensitive = true
}
variable "DASHED_SUBDOMAIN" {
  sensitive = true
}
variable "REGION" {
  sensitive = true
}
variable "security_group_id" {
  sensitive = true
}
variable "server_image" {
  sensitive = true
}
variable "subnet_ids" {
  sensitive = true
}
variable "aws_lb_target_group_arn" {
  sensitive = true
}
variable "efs_volume" {
  sensitive = true
}