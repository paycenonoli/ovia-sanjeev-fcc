# Create a variable for VPC cidr block
variable "ovia_vpc_cidr" {
  description = "cidr block for ovia-vpc"
#   default = "10.0.0.0/16"
  type = string
}