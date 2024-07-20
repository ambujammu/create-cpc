# Creating virtual networks
resource "aws_vpc" "koda_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "koda-vpc"
  }
}