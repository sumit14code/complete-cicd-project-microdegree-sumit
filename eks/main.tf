provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_eks_cluster" "microdegree" {
  name     = "microdegree-cluster"
  role_arn = aws_iam_role.microdegree_cluster_role.arn

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = data.aws_security_group.default.ids
  }
}

resource "aws_eks_node_group" "microdegree" {
  cluster_name    = aws_eks_cluster.microdegree.name
  node_group_name = "microdegree-node-group"
  node_role_arn   = aws_iam_role.microdegree_node_group_role.arn
  subnet_ids      = data.aws_subnets.default.ids

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  instance_types = ["t2.small"]

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = data.aws_security_group.default.ids
  }
}

resource "aws_iam_role" "microdegree_cluster_role" {
  name = "microdegree-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "microdegree_cluster_role_policy" {
  role       = aws_iam_role.microdegree_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "microdegree_node_group_role" {
  name = "microdegree-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "microdegree_node_group_role_policy" {
  role       = aws_iam_role.microdegree_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "microdegree_node_group_cni_policy" {
  role       = aws_iam_role.microdegree_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "microdegree_node_group_registry_policy" {
  role       = aws_iam_role.microdegree_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
