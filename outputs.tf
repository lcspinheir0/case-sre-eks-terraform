output "vpc_id" { value = module.vpc.vpc_id }
output "private_subnet_ids" { value = module.vpc.private_subnets }
output "eks_cluster_name" { value = module.eks.cluster_name }
output "eks_cluster_endpoint" { value = module.eks.cluster_endpoint }
output "node_groups" {
  value = module.eks.eks_managed_node_groups
}

output "ecr_repository_url" { value = module.ecr.repository_url }
