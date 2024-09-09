provider "aws" {
  region = "us-east-1"
}

# Create an IAM Role for the EC2 instance to access EKS, CloudFormation, and EC2
resource "aws_iam_role" "eks_role" {
  name = "eks-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "eks_iam_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_iam_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudformation_iam_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

# Create an EC2 instance to set up EKS cluster
resource "aws_instance" "eks_instance" {
  ami           = "ami-0182f373e66f89c85"  # Use an appropriate AMI for your region
  instance_type = "t2.micro"
  key_name      = "project"
  security_groups = ["default"]

  iam_instance_profile = aws_iam_instance_profile.eks_instance_profile.name
  user_data = <<-EOF
    #!/bin/bash
    # Install AWS CLI, eksctl, kubectl
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.3/2024-04-19/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin
    kubectl version --short --client

    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    eksctl version

    # Create the EKS cluster
    eksctl create cluster --name microdegree --region us-east-1 --node-type t2.small --nodes-min 2 --nodes-max 2

  EOF

  tags = {
    Name = "eks-setup-instance"
  }
}

# Attach the IAM role to the EC2 instance
resource "aws_iam_instance_profile" "eks_instance_profile" {
  name = "eks-instance-profile"
  role = aws_iam_role.eks_role.name
}


# Data source to get default VPC for security group
data "aws_vpc" "default" {
  default = true
}
