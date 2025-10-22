resource "aws_eks_node_group" "EKSNodeGroup" {
  cluster_name    = "${var.project_name}-eks"
  node_group_name = "${var.project_name}_NodeGroup"
  ami_type        = var.AmiTypeInstance
  instance_types  = [var.InstanceTypes[0]]
  node_role_arn   = aws_iam_role.NodeInstanceRole.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.scaling_config["default_config"].desired_size
    max_size     = var.scaling_config["default_config"].max_size
    min_size     = var.scaling_config["default_config"].min_size
  }

  depends_on = [aws_eks_cluster.eks]

  tags = {
    Name = "${var.project_name}-EKSNodeGroup"
  }
}