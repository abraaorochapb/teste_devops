resource "aws_security_group" "ControlPlaneSG" {
  name        = "${var.project_name}_ControlPlaneSG"
  description = "Enables access to all VPC protocols and IPs"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = {
    Name = "${var.project_name}-ControlPlaneSG"
  }
}

resource "aws_eks_cluster" "eks" {
  name     = "${var.project_name}-eks"
  role_arn = aws_iam_role.EKSServiceRole.arn
  version  = var.eks_version

  vpc_config {
    security_group_ids = [aws_security_group.ControlPlaneSG.id]
    subnet_ids         = var.private_subnet_ids
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eks-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}