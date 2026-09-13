locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix              = "${var.project_name}-${var.environment}"
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  database_subnet_cidrs    = var.database_subnet_cidrs
  common_tags              = local.common_tags
}
