terraform {
 required_providers {
 aws = {
  source = "hashicorp/aws"
  version = "~>4.67"
 }
}
 required_version = ">1.2.0"
}

resource "aws_vpc" "Prj2-VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "Prj2-VPC"
  }
}

resource "aws_eip" "Jenkins-Master" {
  instance = "${aws_instance.Master-controller.id}"
  vpc      = true
}

resource "aws_eip" "Kube-Master" {
  instance = "${aws_instance.Kube-Master.id}"
  vpc      = true
}

resource "aws_eip" "Kube-Worker1" {
  instance = "${aws_instance.Kube-Worker1.id}"
  vpc      = true
}

resource "aws_eip" "Kube-Worker2" {
  instance = "${aws_instance.Kube-Worker2.id}"
  vpc      = true
}

resource "aws_subnet" "Prj2-SN1" {
  cidr_block = "${cidrsubnet(aws_vpc.Prj2-VPC.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.Prj2-VPC.id}"
  availability_zone = "us-east-2a"
}

resource "aws_route_table" "My-public-route" {
  vpc_id = "${aws_vpc.Prj2-VPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.My-Prj2-igw.id}"
  }
  
  tags = {
    Name = "My-public-route"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.Prj2-SN1.id}"
  route_table_id = "${aws_route_table.My-public-route.id}"
}

//security-groups to allow all ingress
resource "aws_security_group" "ingress-all-test" {
name = "allow-all-sg"
vpc_id = "${aws_vpc.Prj2-VPC.id}"
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 0
to_port = 0
protocol = "-1"
  }

  
// egress rule to override Terraform default which doesn't allow all traffic
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}


resource "aws_internet_gateway" "My-Prj2-igw" {
  vpc_id = "${aws_vpc.Prj2-VPC.id}"
  tags = {
   Name = "My-Prj2-igw"
  }
}



resource "aws_instance" "Master-controller" {
 ami           = "ami-05fb0b8c1424f266b"
 instance_type = "t2.micro"
 key_name = "Ohio-Pem"
 vpc_security_group_ids = [aws_security_group.ingress-all-test.id]
 user_data = <<-EOF
 	       #!/bin/bash
               touch /home/ubuntu/testuserdat.txt
	       EOF
 tags = {
  Name  = "Master-Controller"
  OS    = "Ubuntu 20.04"
 }
 subnet_id = "${aws_subnet.Prj2-SN1.id}"
}

resource "aws_instance" "Kube-Master" {
 ami           = "ami-05fb0b8c1424f266b"
 instance_type = "t2.medium"
 key_name = "Ohio-Pem"
 vpc_security_group_ids = [aws_security_group.ingress-all-test.id]
 tags = {
  Name  = "Kube-Master"
  OS    = "Ubuntu 20.04"
 }
subnet_id = "${aws_subnet.Prj2-SN1.id}"
}

resource "aws_instance" "Kube-Worker1" {
 ami           = "ami-05fb0b8c1424f266b"
 instance_type = "t2.micro"
 key_name = "Ohio-Pem"
 vpc_security_group_ids = [aws_security_group.ingress-all-test.id]
 tags = {
  Name  = "Kube-Worker1"
  OS    = "Ubuntu 20.04"
 }
subnet_id = "${aws_subnet.Prj2-SN1.id}"
}

resource "aws_instance" "Kube-Worker2" {
 ami           = "ami-05fb0b8c1424f266b"
 instance_type = "t2.micro"
 key_name = "Ohio-Pem"
 vpc_security_group_ids = [aws_security_group.ingress-all-test.id]
 tags = {
  Name  = "Kube-Worker2"
  OS    = "Ubuntu 20.04"
 }
subnet_id = "${aws_subnet.Prj2-SN1.id}"
}


output "private_ips" {
 value = {
  Master-controller        = aws_instance.Master-controller.private_ip
  Kube-Master   = aws_instance.Kube-Master.private_ip
  Kube-Worker1  = aws_instance.Kube-Worker1.private_ip
  Kube-Worker2  = aws_instance.Kube-Worker2.private_ip
 }
}

output "public_ips" {
 value = {
  Master-controller        = aws_instance.Master-controller.public_ip
  Kube-Master   = aws_instance.Kube-Master.public_ip
  Kube-Worker1  = aws_instance.Kube-Worker1.public_ip
  Kube-Worker2  = aws_instance.Kube-Worker2.public_ip
 }
}
