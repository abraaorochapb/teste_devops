output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.eks.id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "eks_version" {
  description = "EKS version"
  value       = aws_eks_cluster.eks.version
}

output "NodeInstanceRole" {
  value = aws_iam_role.NodeInstanceRole.arn
}