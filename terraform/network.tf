resource "aws_vpc" "gke_vpc" {
  cidr_block = "10.0.0.0/16"
  
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_classiclink = false
  enable_classiclink_dns_support = false
  assign_generated_ipv6_cidr_block = false
  tags = {
    "Name"="gke-vpc"
  }
}

#------------------Public Subnets--------------------------
resource "aws_subnet" "public_az1" {
  vpc_id     = aws_vpc.gke_vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-az1"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id     = aws_vpc.gke_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    Name = "public-az2"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  
}

#------------------Private Subnets------------------------
resource "aws_subnet" "private_az1" {
  vpc_id     = aws_vpc.gke_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-az1"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id     = aws_vpc.gke_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-az2"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}




#--------------"IGW and NGW"---------------
resource "aws_internet_gateway" "gke_igw" {
  vpc_id = aws_vpc.gke_vpc.id
  tags = {
    Name = "gke-igw"
  }
}

resource "aws_eip" "nat_ip" {

}

resource "aws_nat_gateway" "gke_nat" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.public_az1.id
}

#-------------------------ROUTETABLES-----------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.gke_vpc.id
}

resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gke_igw.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.gke_vpc.id
}

resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.gke_nat.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_az1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private_az2.id
  route_table_id = aws_route_table.private.id
}

#--------------------------SG--------------------------
resource "aws_security_group" "public_sg" {
  name        = "pub-sec-group"
  description = "Allow some tcp traffic from anywhere"
  vpc_id = aws_vpc.gke_vpc.id
  tags = {
    Name = "public-gke-sg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}