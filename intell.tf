# Creating virtual networks
resource "aws_vpc" "intell_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "intell-vpc"
  }
}

# Creating Subnet for web server
resource "aws_subnet" "intell_subnet" {
  vpc_id     = aws_vpc.intell_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "intell-subnet"
  }
}

# Creating Subnet for database server
resource "aws_subnet" "intell_subnet_database" {
  vpc_id     = aws_vpc.intell_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "intell-subnet-databse"
  }
}

# Creating Subnet for application server
resource "aws_subnet" "intell_subnet_app" {
  vpc_id     = aws_vpc.intell_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "intell-subnet-app"
  }
}

# intell internet gateway
resource "aws_internet_gateway" "intell-gw" {
  vpc_id = aws_vpc.intell_vpc.id

  tags = {
    Name = "intell-ig"
  }
}

#Creating Public Route Table
resource "aws_route_table" "intell-route1" {
  vpc_id = aws_vpc.intell_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.intell-gw.id
  }

  tags = {
    Name = "intell-route1"
  }
}

#Creating Private Route Table
resource "aws_route_table" "intell-route-private" {
  vpc_id = aws_vpc.intell_vpc.id

  tags = {
    Name = "intell-route1-private"
  }
}

# Map public subnet with public route
resource "aws_route_table_association" "public-web-route" {
  subnet_id      = aws_subnet.intell_subnet.id
  route_table_id = aws_route_table.intell-route1.id
}
resource "aws_route_table_association" "public-app-route" {
  subnet_id      = aws_subnet.intell_subnet_app.id
  route_table_id = aws_route_table.intell-route1.id
}

# Map private subnet with private route
resource "aws_route_table_association" "public-database-route" {
  subnet_id      = aws_subnet.intell_subnet_database.id
  route_table_id = aws_route_table.intell-route-private.id
}

# Create NACLs
resource "aws_network_acl" "web_nacl" {
  vpc_id = aws_vpc.intell_vpc.id

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
    Name = "intell-web-nacl"
  }
}

# Subnet association to nacl-web
resource "aws_network_acl_association" "web-subnet-nacl" {
  network_acl_id = aws_network_acl.web_nacl.id
  subnet_id      = aws_subnet.intell_subnet.id
}

# Create NACLs for app
resource "aws_network_acl" "app_nacl" {
  vpc_id = aws_vpc.intell_vpc.id

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
    Name = "intell-app-nacl"
  }
}

# Subnet association to nacl-app
resource "aws_network_acl_association" "app-subnet-nacl" {
  network_acl_id = aws_network_acl.app_nacl.id
  subnet_id      = aws_subnet.intell_subnet_app.id
}

# Create NACLs for DB
resource "aws_network_acl" "db_nacl" {
  vpc_id = aws_vpc.intell_vpc.id

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
    Name = "intell-db-nacl"
  }
}

# Subnet association to nacl-db
resource "aws_network_acl_association" "db-subnet-nacl" {
  network_acl_id = aws_network_acl.db_nacl.id
  subnet_id      = aws_subnet.intell_subnet_database.id
}

# Web security group rule
resource "aws_security_group" "intell_sg_web" {
  name        = "intell_sg_web"
  description = "Allow SSH & HTTP traffic"
  vpc_id      = aws_vpc.intell_vpc.id

  tags = {
    Name = "intell-sg-web-firewall"
  }
}

# Web security group rule - SSH
resource "aws_vpc_security_group_ingress_rule" "intell_sg_web_ssh" {
  security_group_id = aws_security_group.intell_sg_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# web security group rule - HTTP
resource "aws_vpc_security_group_ingress_rule" "intell_sg_web_http" {
  security_group_id = aws_security_group.intell_sg_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# app security group rule
resource "aws_security_group" "intell_app_sg" {
  name        = "intell_app_sg"
  description = "Allow SSH & 3000 traffic"
  vpc_id      = aws_vpc.intell_vpc.id

  tags = {
    Name = "intell-app-sg-firewall"
  }
}

# app security group rule - SSH
resource "aws_vpc_security_group_ingress_rule" "intell_app_sg_ssh" {
  security_group_id = aws_security_group.intell_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# app security group rule - HTTP
resource "aws_vpc_security_group_ingress_rule" "intell_app_sg_3000" {
  security_group_id = aws_security_group.intell_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

# db security group rule
resource "aws_security_group" "intell_db_sg" {
  name        = "intell_db_sg"
  description = "Allow SSH & Mysql traffic"
  vpc_id      = aws_vpc.intell_vpc.id

  tags = {
    Name = "intell-db-sg-firewall"
  }
}

# db security group rule - SSH
resource "aws_vpc_security_group_ingress_rule" "intell_db_sg_ssh" {
  security_group_id = aws_security_group.intell_db_sg.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# db security group rule - mysql
resource "aws_vpc_security_group_ingress_rule" "intell_db_sg_mysql" {
  security_group_id = aws_security_group.intell_db_sg.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}