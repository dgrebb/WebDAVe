variable "AWS_ACCESS_KEY" {
  sensitive = true
}

variable "AWS_SECRET_KEY" {
  sensitive = true
}

variable "AWS_REGION" {
  sensitive = true
}

variable "DOMAIN" {
  sensitive = true
}

variable "SUBDOMAIN" {
  sensitive = true
}

variable "DASHED_SUBDOMAIN" {
  sensitive = true
}

variable "load_balancer_security_group_id" {
  sensitive = true
}

variable "subnets" {}
