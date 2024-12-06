terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "amazon_clone_vpc" {
  cidr_block = "10.0.0.0/16" 
  instance_tenancy = "default"
  
  tags = {
    Name = "amazon-clone-vpc"
  }
}

resource "aws_subnet" "amazon_clone_subnet" {
  vpc_id            = aws_vpc.amazon_clone_vpc.id
  cidr_block        = "10.0.1.0/24"  
  availability_zone = "us-east-1a"    
  
  tags = {
    Name = "amazon-clone-subnet"
  }
}

resource "aws_internet_gateway" "amazon_clone_igw" {
  vpc_id = aws_vpc.amazon_clone_vpc.id

  tags = {
    Name = "amazon-clone-igw"
  }
}

resource "aws_security_group" "amazon_clone_sg" {
  name        = "amazon-clone-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.amazon_clone_vpc.id

  ingress = [
    for port in [22, 80, 443, 8080, 9000,3000,9090,9100] : {
      description        = "inbound rules"  
        from_port        = port
        to_port          = port
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        security_groups  = []
        self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "amazon-clone-sg"
  }
}

resource "aws_instance" "amazon_clone_instance" {
  ami                          = "ami-005fc0f236362e99f"  
  instance_type                = "t2.large"  
  subnet_id                    = aws_subnet.amazon_clone_subnet.id
  vpc_security_group_ids       = [aws_security_group.amazon_clone_sg.id]
  user_data                    = templatefile("./install_jenkins.sh", {})
  associate_public_ip_address  = true
  key_name                     = "NorthVirginia-PPK-12"  

  tags = {
    Name = "amazon-clone-instance"
  }
}
