# Creating virtual networks
resource "aws_vpc" "tcs_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tcs-vpc"
  }
}

# Creating Subnet for web server
resource "aws_subnet" "tcs_subnet" {
  vpc_id     = aws_vpc.tcs_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "tcs-subnet"
  }
}

# Creating Subnet for database server
resource "aws_subnet" "tcs_subnet_database" {
  vpc_id     = aws_vpc.tcs_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "tcs-subnet-databse"
  }
}

# Creating Subnet for application server
resource "aws_subnet" "tcs_subnet_app" {
  vpc_id     = aws_vpc.tcs_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "tcs-subnet-app"
  }
}

# tcs internet gateway
resource "aws_internet_gateway" "tcs-gw" {
  vpc_id = aws_vpc.tcs_vpc.id

  tags = {
    Name = "tcs-ig"
  }
}

#Creating Public Route Table
resource "aws_route_table" "tcs-route1" {
  vpc_id = aws_vpc.tcs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tcs-gw.id
  }

  tags = {
    Name = "tcs-route1"
  }
}

#Creating Private Route Table
resource "aws_route_table" "tcs-route-private" {
  vpc_id = aws_vpc.tcs_vpc.id

  tags = {
    Name = "tcs-route1-private"
  }
}

# Map public subnet with public route
resource "aws_route_table_association" "public-web-route" {
  subnet_id      = aws_subnet.tcs_subnet.id
  route_table_id = aws_route_table.tcs-route1.id
}
resource "aws_route_table_association" "public-app-route" {
  subnet_id      = aws_subnet.tcs_subnet_app.id
  route_table_id = aws_route_table.tcs-route1.id
}

# Map private subnet with private route
resource "aws_route_table_association" "public-database-route" {
  subnet_id      = aws_subnet.tcs_subnet_database.id
  route_table_id = aws_route_table.tcs-route-private.id
}

# Create NACLs
resource "aws_network_acl" "web_nacl" {
  vpc_id = aws_vpc.tcs_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "tcs-web-nacl"
  }
}

# Subnet association to nacl-web
resource "aws_network_acl_association" "web-subnet-nacl" {
  network_acl_id = aws_network_acl.web_nacl.id
  subnet_id      = aws_subnet.tcs_subnet.id
}

# Create NACLs for app
resource "aws_network_acl" "app_nacl" {
  vpc_id = aws_vpc.tcs_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "tcs-app-nacl"
  }
}

# Subnet association to nacl-app
resource "aws_network_acl_association" "app-subnet-nacl" {
  network_acl_id = aws_network_acl.app_nacl.id
  subnet_id      = aws_subnet.tcs_subnet_app.id
}

# Create NACLs for DB
resource "aws_network_acl" "db_nacl" {
  vpc_id = aws_vpc.tcs_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "tcs-db-nacl"
  }
}

# Subnet association to nacl-db
resource "aws_network_acl_association" "db-subnet-nacl" {
  network_acl_id = aws_network_acl.db_nacl.id
  subnet_id      = aws_subnet.tcs_subnet_database.id
}

# Web security group rule
resource "aws_security_group" "tcs_sg_web" {
  name        = "tcs_sg_web"
  description = "Allow SSH & HTTP traffic"
  vpc_id      = aws_vpc.tcs_vpc.id

  tags = {
    Name = "tcs-sg-web-firewall"
  }
}

# Web security group rule - SSH
resource "aws_vpc_security_group_ingress_rule" "tcs_sg_web_ssh" {
  security_group_id = aws_security_group.tcs_sg_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# web security group rule - HTTP
resource "aws_vpc_security_group_ingress_rule" "tcs_sg_web_http" {
  security_group_id = aws_security_group.tcs_sg_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# app security group rule
resource "aws_security_group" "tcs_app_sg" {
  name        = "tcs_app_sg"
  description = "Allow SSH & 8080 traffic"
  vpc_id      = aws_vpc.tcs_vpc.id

  tags = {
    Name = "tcs-app-sg-firewall"
  }
}

# app security group rule - SSH
resource "aws_vpc_security_group_ingress_rule" "tcs_app_sg_ssh" {
  security_group_id = aws_security_group.tcs_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# app security group rule - HTTP
resource "aws_vpc_security_group_ingress_rule" "tcs_app_sg_8080" {
  security_group_id = aws_security_group.tcs_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

# db security group rule
resource "aws_security_group" "tcs_db_sg" {
  name        = "tcs_db_sg"
  description = "Allow SSH & Postgres traffic"
  vpc_id      = aws_vpc.tcs_vpc.id

  tags = {
    Name = "tcs-db-sg-firewall"
  }
}

# db security group rule - SSH
resource "aws_vpc_security_group_ingress_rule" "tcs_db_sg_ssh" {
  security_group_id = aws_security_group.tcs_db_sg.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# db security group rule - Postgres
resource "aws_vpc_security_group_ingress_rule" "tcs_db_sg_postgres" {
  security_group_id = aws_security_group.tcs_db_sg.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 5342
  ip_protocol       = "tcp"
  to_port           = 5432
}