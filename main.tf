terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name    = "${var.project}-vpc"
  cidr    = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Ambiente = var.env
    Project  = var.project
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = "${var.project}-eks"
  cluster_version = var.kubernetes_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      desired_size   = 1
      max_size       = 1
      min_size       = 1
      instance_types = ["t3.medium"]
      name           = "${var.project}-nodegroup"
      subnet_ids     = module.vpc.private_subnets
      tags = {
        Ambiente = var.env
      }
    }
  }

  tags = {
    Ambiente = var.env
    Project  = var.project
  }
}

module "ecr" {
  source                          = "terraform-aws-modules/ecr/aws"
  version                         = "~> 1.0"
  repository_name                 = "${var.project}-ecr"
  repository_image_tag_mutability = "MUTABLE"
  repository_encryption_type      = "AES256"
  create_lifecycle_policy         = false
  tags = {
    Ambiente = var.env
    Project  = var.project
  }
}
