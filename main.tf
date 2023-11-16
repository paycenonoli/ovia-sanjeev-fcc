# Define provider
provider "aws" {
  region  = "us-east-2"
  profile = "default"
}

# 1. Create vpc
# 2. Create Internet Gateway
# 3. Create Custom Route Table
# 4. Create a subnet
# 5. Associate subnet with Route Table
# 6. Create Seccurity Group to allow ports 22, 80, 443
# 7. Create a network interface with an IP in the subnet that was created in step 4
# 8. Assign an elastic IP to the network interface created in step 7
# 9. Create an Ubuntu server and install/ enable apache2

# Create a VPC
# resource "aws_vpc" "ovia-vpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "Production"
#   }
# }
# # Create subnets
# resource "aws_subnet" "ovia-subnet" {
#   vpc_id     = aws_vpc.ovia-vpc.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "Prod-subnet"
#   }
# }

# resource "aws_vpc" "ovia-vpc-2" {
#   cidr_block = "10.1.0.0/16"
#   tags = {
#     Name = "Dev"
#   }
# }

# resource "aws_subnet" "ovia-subnet-2" {
#   vpc_id     = aws_vpc.ovia-vpc-2.id
#   cidr_block = "10.1.1.0/24"

#   tags = {
#     Name = "Dev-subnet"
#   }
# }

# #Create an EC2 instance
# resource "aws_instance" "ovia-instance" {
#   ami                     = "ami-0e83be366243f524a"
#   instance_type           = "t2.micro"
#   tags = {
#     Name = "ovia-ubuntu"
#   }
# }

# Create a VPC
resource "aws_vpc" "ovia-vpc" {
  cidr_block = "10.0.0.0/16"
  tags ={
    Name = "Production"
  }
}
# Create an Internet Gateway
resource "aws_internet_gateway" "ovia-igw" {
  vpc_id = aws_vpc.ovia-vpc.id
  
}
# Create a Route Table
resource "aws_route_table" "prod-rtb" {
  vpc_id = aws_vpc.ovia-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ovia-igw.id
  }

  tags = {
    Name = "Prod"
  }
}
# Create a subnet
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.ovia-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Prod_subnet"
  }
}
# Create route table association
resource "aws_route_table_association" "rtb-asso" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-rtb.id
}
# Create security group
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.ovia-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# Create Network Interface
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}
# Assign an Elastic IP
resource "aws_eip" "ovia-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.ovia-igw]
}

# Get value of Elastic IP
output "server_public_ip" {
  value = aws_eip.ovia-eip.public_ip
}
# Create an EC2 instance
resource "aws_instance" "ovia-instance" {
  ami                     = "ami-0e83be366243f524a"
  instance_type           = "t2.micro"
  availability_zone       = "us-east-2a"
  key_name                = "ovia-keys"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo My very first web server > /var/www/html/index.html'
              EOF
  tags = {
    Name = "web-server"
  }
 

}