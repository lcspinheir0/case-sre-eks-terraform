variable "aws_region" {
  type        = string
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project" {
  description = "Nome do projeto para tags"
  type        = string
  default     = "case-sre-eks-terraform"
}

variable "env" {
  description = "Ambiente do provisionamento"
  type        = string
  default     = "dev"
}


variable "public_subnets" {
  description = "Blocos CIDR das subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "Blocos CIDR das subnets privadas"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}


variable "kubernetes_version" {
  type        = string
  description = "Versão do Kubernetes para o cluster EKS"
  default     = "1.29"
}
