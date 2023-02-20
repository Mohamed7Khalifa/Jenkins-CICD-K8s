
resource "aws_iam_role" "eks_nodes_role" {
  name = "eks-node-role"

  assume_role_policy = <<POLICY
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
    POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_Worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2_Container_Registry_ReadOnly_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  
  node_group_name = "eks-nodes"
  
  node_role_arn = aws_iam_role.eks_nodes_role.arn
  
  subnet_ids = [
    aws_subnet.private_az1.id,
    aws_subnet.private_az2.id
    ]
  
  scaling_config {
    # number of worker nodes
    desired_size = 1
    max_size = 1
    min_size = 1
  }
  
  ami_type = "AL2_x86_64"
  
  capacity_type = "ON_DEMAND"
  
  disk_size = 20
  
  force_update_version = false
  
  instance_types = ["t3.small"]
  
  labels = {
    role = "eks-node-role"
  }
  
  version = "1.24"

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKS_Worker_node_policy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2_Container_Registry_ReadOnly_Policy,
  ]
}




