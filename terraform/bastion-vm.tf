resource "aws_instance" "bastion_vm" {
  ami = "ami-0557a15b87f6559cf"
  # ami = "ami-0dfcb1ef8550277af"
  instance_type               = "t2.small"
  key_name                    = "ansible"
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.my_instance_profile.id
  tags = {
    Name = "jumphost"
  }
  # provisioner "local-exec" {
  #     command = "echo Public EC2 ip: ${self.public_ip} >> ./public_ip.txt"
  #   }
  # connection {
  #   type     = "ssh"
  #   user     = "ubuntu"
  #   private_key = file("~/.EC2_instances/ansible.pem") 
  #   host     = self.public_ip 
  #   }
}

resource "aws_iam_instance_profile" "my_instance_profile" {
  name = "my-ec2-instance-profile"

  role = aws_iam_role.nodes_general.id
  # aws_iam_role.my_role.name

}

resource "aws_security_group" "public_sg" {
  name        = "pub-sec-group"
  description = "Allow HTTP traffic from anywhere"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "public-sg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
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