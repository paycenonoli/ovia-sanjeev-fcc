# Define provider
provider "aws" {
  region  = "us-east-2"
  profile = "default"
}

# Create a VPC
resource "aws_vpc" "ovia-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}
# Create subnets
resource "aws_subnet" "ovia-subnet" {
  vpc_id     = aws_vpc.ovia-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "prod-subnet"
  }
}

# #Create an EC2 instance
# resource "aws_instance" "ovia-instance" {
#   ami                     = "ami-0e83be366243f524a"
#   instance_type           = "t2.micro"
#   tags = {
#     Name = "ovia-ubuntu"
#   }
# }