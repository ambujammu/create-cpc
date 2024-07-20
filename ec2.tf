# ec2 instance
resource "aws_instance" "koda_web_server" {
  ami           = "ami-ami-0aff18ec83b712f05"
  instance_type = "t2.micro"
  key_name = "papu"
  subnet_id = aws_subnet.tcs_subnet.id
  vpc_security_group_ids = aws_security_group.tcs_sg_web.id
  user_data = file("app.sh)

  tags = {
    Name = "HelloWorld"
  }
}