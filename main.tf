provider "aws" {
  region  = var.aws_region
  alias   = "virginia"
  profile = "personal"

  default_tags {
    tags = {
      "Environment" = var.environment
      "ManagedBy"   = var.managed_by
      "Owner"       = var.owner
      "Project"     = var.project
    }
  }
}

locals {
  global_tags = {
    "Environment" = var.environment
    "ManagedBy"   = var.managed_by
    "Owner"       = var.owner
    "Project"     = var.project
  }
}

data "aws_route53_zone" "main" {
  name = var.domain_name
}

terraform {
  required_version = ">= 0.13"
  backend "s3" {
    bucket = "s3-777790172967-terraform-states"
    key    = "ecs_wordpress.tfstate"
    region = "us-east-1"
    # dynamodb_table = "terraform-locks"
    encrypt = false
    # use_lockfile = true # Native s3 locking
  }
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3" #3.7.1
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5" #5.94.1
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3" #3.2.3
    }
  }
}

module "vpc" {
  source = "./modules/ecs_core/networking"

  environment        = var.environment
  project            = var.project
  vpc_cidr           = var.vpc_cidr
  single_nat_gateway = var.single_nat_gateway
  global_tags        = local.global_tags
}

module "security_groups" {
  source = "./modules/ecs_core/segurity_groups"

  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
  global_tags = local.global_tags

  depends_on = [module.vpc]
}

module "service_discovery" {
  source = "./modules/ecs_core/services_discovery"

  namespace_name         = "local"
  discovery_service_name = ["wordpress", "postgresql", "reactjs", "nestjs"]
  vpc_id                 = module.vpc.vpc_id
  environment            = var.environment

  depends_on = [module.vpc]
}

module "route53" {
  source = "./modules/ecs_core/route53"

  domain_name  = var.domain_name
  zone_id      = data.aws_route53_zone.main.zone_id
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.zone_id
  global_tags  = local.global_tags
}

module "acm" {
  source = "./modules/ecs_core/acm"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.main.zone_id
  global_tags = local.global_tags
}

module "alb" {
  source = "./modules/ecs_core/alb"

  alb_name                    = "alb-${var.project}-${var.environment}"
  alb_internal                = false
  alb_security_groups         = [module.security_groups.sg_alb_id]
  alb_subnets                 = module.vpc.public_subnets
  vpc_id                      = module.vpc.vpc_id
  wordpress_target_group_name = "wordpress-tg"
  react_target_group_name     = "react-tg"
  domain_name                 = var.domain_name
  global_tags                 = local.global_tags
  enable_access_logs          = false
  enable_waf                  = false
  certificate_arn             = module.acm.acm_certificate_arn

  depends_on = [module.vpc, module.security_groups]
}

module "ecs_cluster" {
  source = "./modules/ecs_core/cluster"

  environment = var.environment
  project     = var.project
  global_tags = local.global_tags
}

module "efs_postgresql" {
  source = "./modules/ecs_core/storage/efs"

  efs_name              = "postgresql"
  environment           = var.environment
  project               = var.project
  private_subnet_ids    = module.vpc.private_subnets
  efs_security_group_id = module.security_groups.sg_efs_id

  depends_on = [module.vpc, module.security_groups]

}

module "efs_wordpress" {
  source = "./modules/ecs_core/storage/efs"

  efs_name              = "wordpress"
  environment           = var.environment
  project               = var.project
  private_subnet_ids    = module.vpc.private_subnets
  efs_security_group_id = module.security_groups.sg_efs_id

  depends_on = [module.vpc, module.security_groups]
}

module "postgresql_service" {
  source = "./modules/ecs_services/postgresql"

  efs_id         = module.efs_postgresql.efs_id
  ecs_cluster_id = module.ecs_cluster.ecs_cluster_id
  desired_count  = 1

  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [module.security_groups.sg_postgresql_id]
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  registry_arn       = module.service_discovery.service_arns["postgresql"]

  global_tags = local.global_tags

}

module "wordpress_service" {
  source = "./modules/ecs_services/wordpress"

  efs_id         = module.efs_wordpress.efs_id
  ecs_cluster_id = module.ecs_cluster.ecs_cluster_id
  desired_count  = 1

  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [module.security_groups.sg_wordpress_id]
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  registry_arn       = module.service_discovery.service_arns["wordpress"]
  target_group_arn   = module.alb.wordpress_target_group_arn

  global_tags = local.global_tags

  depends_on = [module.efs_wordpress]
}

