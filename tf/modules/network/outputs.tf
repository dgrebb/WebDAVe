output "vpc_id" {
  value = aws_default_vpc.default.id
  sensitive = true
}

output "subnet_ids" {
  value = [
    for subnet in aws_default_subnet.default_subnets : subnet.id
  ]
}

output "aws_lb_target_group_arn" {
  value = aws_lb_target_group.webdav_lb_target_group.arn
  sensitive = true
}