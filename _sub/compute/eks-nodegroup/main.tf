resource "aws_eks_node_group" "group" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  ami_type        = var.gpu_ami ? "AL2_x86_64_GPU" : "AL2_x86_64"

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  remote_access {
    ec2_ssh_key               = var.ec2_ssh_key
    # source_security_group_ids = var.source_security_group_ids
  }

  tags = {
    "Name" = "eks-${var.cluster_name}-${var.node_group_name}"
  }

}
