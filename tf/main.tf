# uncomment if you'd like to store Terraform state in s3
# also see the `tf/provider.tf` file and uncomment the backend section
module "state" {
  source                 = "./modules/state"
  terraform_state_bucket = var.terraform_state_bucket
}

module "cluster" {
  source                  = "./modules/cluster"
  SUBDOMAIN               = var.SUBDOMAIN
  DASHED_SUBDOMAIN        = var.DASHED_SUBDOMAIN
  REGION                  = var.AWS_REGION
  security_group_id       = module.security.security_group_id
  server_image            = module.image.webdav_server_image
  subnet_ids              = module.network.subnet_ids
  aws_lb_target_group_arn = module.network.aws_lb_target_group_arn
  efs_volume              = module.filesystem.efs_volume
}

module "filesystem" {
  source            = "./modules/filesystem"
  DASHED_SUBDOMAIN  = var.DASHED_SUBDOMAIN
  subnet_ids        = module.network.subnet_ids
  security_group_id = module.security.security_group_id
}

module "image" {
  source    = "./modules/image"
  SUBDOMAIN = var.SUBDOMAIN
}

module "logs" {
  source    = "./modules/logs"
  SUBDOMAIN = var.SUBDOMAIN
}

module "network" {
  source                          = "./modules/network"
  AWS_ACCESS_KEY                  = var.AWS_ACCESS_KEY
  AWS_SECRET_KEY                  = var.AWS_SECRET_KEY
  DOMAIN                          = var.DOMAIN
  SUBDOMAIN                       = var.SUBDOMAIN
  DASHED_SUBDOMAIN                = var.DASHED_SUBDOMAIN
  REGION                          = var.AWS_REGION
  load_balancer_security_group_id = module.security.load_balancer_security_group_id
  subnets                         = var.subnets
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
}
