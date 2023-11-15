# Define provider
provider "aws" {
  region  = "us-east-2"
  profile = "default"
}
#Create an EC2 instance
resource "aws_instance" "ovia-instance" {
  ami                     = "ami-0e83be366243f524a"
  instance_type           = "t2.micro"
  tags = {
    Name = "ovia-ubuntu"
  }
}