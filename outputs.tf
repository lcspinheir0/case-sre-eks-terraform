output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_nodegroup_role_arn" {
  value = aws_iam_role.eks_nodegroup.arn
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.main.arn
}

output "eks_nodegroup_name" {
  value = aws_eks_node_group.main.node_group_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.main.repository_url
}
