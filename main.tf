terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_vpc" "my_tf_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_tf_vpc"
  }
}

resource "aws_subnet" "my_tf_subnet" {
  vpc_id     = aws_vpc.my_tf_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "my_tf_subnet"
  }
}

resource "aws_security_group" "my_tf_sg" {
  name        = "my_tf_sg"
  description = "Allow ping inbound traffic"
  vpc_id      = aws_vpc.my_tf_vpc.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_tf_sg"
  }
}

resource "aws_internet_gateway" "my_tf_ig" {
  vpc_id = aws_vpc.my_tf_vpc.id

  tags = {
    Name = "my_tf_ig"
  }
}

resource "aws_default_route_table" "my_tf_vpc_route_table" {
  default_route_table_id = aws_vpc.my_tf_vpc.main_route_table_id

  tags = {
    Name = "my_tf_vpc_route_table"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_default_route_table.my_tf_vpc_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_tf_ig.id

}

resource "aws_instance" "my_tf_instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.my_tf_sg.id]
  subnet_id                   = aws_subnet.my_tf_subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "my_tf_instance"
  }
}