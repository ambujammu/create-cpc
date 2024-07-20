# Creating virtual networks
resource "aws_vpc" "koda_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "koda-vpc"
  }
}

# Creating Subnet for web server
resource "aws_subnet" "koda_subnet" {
  vpc_id     = aws_vpc.koda_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "koda-subnet"
  }
}