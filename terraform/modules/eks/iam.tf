resource "aws_iam_role" "EKSServiceRole" {
  name = "${var.project_name}-eksrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-eks-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.EKSServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.EKSServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "NodeInstanceRole" {
  name = "${var.project_name}-NodeRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "ssm.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-NodeInstanceRole"
  }
}

resource "aws_iam_role_policy_attachment" "NodeInstanceRole_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.NodeInstanceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "NodeInstanceRole_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.NodeInstanceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "NodeInstanceRole_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.NodeInstanceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "NodeInstanceRole_AmazonSSMFullAccess" {
  role       = aws_iam_role.NodeInstanceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "NodeInstanceRole_AdministratorAccess" {
  role       = aws_iam_role.NodeInstanceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}