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

# Creating Subnet for database server
resource "aws_subnet" "koda_subnet_database" {
  vpc_id     = aws_vpc.koda_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "koda-subnet-databse"
  }
}

# Creating Subnet for application server
resource "aws_subnet" "koda_subnet_app" {
  vpc_id     = aws_vpc.koda_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "koda-subnet-app"
  }
}

# Koda internet gateway
resource "aws_internet_gateway" "koda-gw" {
  vpc_id = aws_vpc.koda_vpc.id

  tags = {
    Name = "koda-ig"
  }
}

#Creating Public Route Table
resource "aws_route_table" "koda-route1" {
  vpc_id = aws_vpc.koda_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.koda-gw.id
  }

  tags = {
    Name = "koda-route1"
  }
}

#Creating Private Route Table
resource "aws_route_table" "koda-route-private" {
  vpc_id = aws_vpc.koda_vpc.id

  tags = {
    Name = "koda-route1-private"
  }
}

# Map public subnet with public route
resource "aws_route_table_association" "public-web-route" {
  subnet_id      = aws_subnet.koda_subnet.id
  route_table_id = aws_route_table.koda-route1.id
}
resource "aws_route_table_association" "public-app-route" {
  subnet_id      = aws_subnet.koda_subnet_app.id
  route_table_id = aws_route_table.koda-route1.id
}