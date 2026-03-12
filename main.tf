terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.29.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }

  backend "s3" {
    bucket = "quotezen-terraform-poc-infra-deploy"
    key    = "terraform/quotezen-poc-monitoring-state"
    region = "us-east-1"
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
        Project              = var.project
        "xal:environment"    = var.xal_environment
        "xal:project"        = var.xal_project
        "xal:owner"          = var.xal_owner
        "xd:project-id"      = var.xd_project_id
        "xd:backup-schedule" = var.xd_backup_schedule
      }
  }
}

module "vpc" {
  source                  = "./modules/vpc"
  environment             = var.environment 
  project                 = var.project
  vpc_cidr                = var.vpc_cidr
  public_subnets_cidr     = var.public_subnets_cidr
  private_subnets_cidr    = var.private_subnets_cidr
  availability_zones      = var.availability_zones
  region                  = var.region
}

module "ecr" {
  source              = "./modules/ecr"
  project             = var.project
  environment         = var.environment
  infra_configuration = var.infra_configuration
}

module "alb" {
  source              = "./modules/alb"
  project             = var.project
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnets
  
  alb_configurations = {
    for service, config in var.infra_configuration :
    service => {
      port            = config.alb.port
      internal        = config.alb.internal
      health_path     = config.alb.health_path
      container_port  = config.alb.container_port
      certificate_arn = config.alb.certificate_arn
    }
  }
}

module "ecs" {
  source                = "./modules/ecs"
  project               = var.project
  environment           = var.environment
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  ecr_urls              = module.ecr.ecr_url
  infra_configuration   = var.infra_configuration
  alb_target_group_arns = module.alb.target_group_arns
  container_ports       = { for k, v in var.infra_configuration : k => v.alb.container_port }
  #rds_secret_name       = module.rds.secret_name
  s3_bucket              = var.s3_bucket
  redis_secret_name      = module.redis.redis_secret_name
  db_secret_name         = var.db_secret_name
  frontend_db_secret_name = var.frontend_db_secret_name
}

#module "rds" {
#  source              = "./modules/rds"
#  project             = var.project
#  environment         = var.environment
#  vpc_id              = module.vpc.vpc_id
#  private_subnet_ids  = module.vpc.private_subnets
#  rds_configuration   = var.rds_configuration
#  vpc_cidr            = var.vpc_cidr
#}


module "redis" {
  source                = "./modules/redis"
  project               = var.project
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  redis_configuration   = var.redis_configuration
  vpc_cidr              = var.vpc_cidr
  ecs_security_group_id = module.ecs.ecs_security_group_id
}
