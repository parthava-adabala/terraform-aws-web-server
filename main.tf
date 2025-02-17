terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.87.0"
    }
  }
}

provider "aws" {
  region     = "us-east-2"
  access_key = "your-access-key"
  secret_key = "your-secret-key"
}

# 1. Create VPC
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "proj-vpc"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "mygw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "proj-gw"
  }
}

# 3. Create Custom Route Table
resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.mygw.id
  }

  tags = {
    Name = "proj-rt"
  }
}

# 4. Create Subnet
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "prod-subnet"
  }
}

# 5. Create Route Table Association
resource "aws_route_table_association" "myrta" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myrt.id
}

# 6. Create Security Group
resource "aws_security_group" "mysg" {
  name   = "allow_web_traffic"
  vpc_id = aws_vpc.myvpc.id

  ingress  {
    description = "allow HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow HTTPS"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_web"
  }
}

# 7. Create Network Interface
resource "aws_network_interface" "myni" {
  subnet_id       = aws_subnet.mysubnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.mysg.id]
}

# 8. Create Public IP
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.myni.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.mygw ]
}

# 9. Create EC2 Instance
resource "aws_instance" "myec2" {
  ami           = "ami-0cb91c7de36eed2cb"
  instance_type = "t2.micro"
  availability_zone = "us-east-2a"
  key_name = "main-key"
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.myni.id
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo "your very first web server" > /var/www/html/index.html'
              EOF
  tags = {
    Name = "Ubuntu"
  }
}

output "public_ip" {
  value = aws_instance.myec2.public_ip
}