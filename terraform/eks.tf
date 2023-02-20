
resource "aws_eks_cluster" "eks_cluster" {
  name     = "iti-cluster"
  role_arn = aws_iam_role.eks_role.arn
  
  version="1.24"
  
  vpc_config {
    endpoint_private_access = false 
    endpoint_public_access = true
    subnet_ids = [
      aws_subnet.public_az1.id,
      aws_subnet.public_az2.id,
      aws_subnet.private_az1.id,
      aws_subnet.private_az2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}
#------------------------"eks role and policy"--------------------------------
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = <<POLICY
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
    POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_role.name
}
