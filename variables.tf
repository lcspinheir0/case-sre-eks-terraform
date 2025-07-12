variable "aws_region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  default     = "10.0.0.0/16"
}

variable "project" {
  description = "Nome do projeto para tags"
  default     = "case-sre-eks-terraform"
}

variable "env" {
  description = "Ambiente do provisionamento"
  default     = "dev"
}

