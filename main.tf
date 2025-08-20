provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "example" {
  ami = "ami-08b138b7cf65145b1"
  instance_type = "t2.micro"
  subnet_id = "subnet-0b22adcab813d1daa"
  vpc_security_group_ids = [aws_security_group.instance.id] 

  user_data = <<-EOF
               #!/bin/bash
               echo "Hello, World" > index.xhtml
               nohup busybox httpd -f -p $[var.server_port] &
               EOF
  
  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }
}


resource "aws_security_group" "instance" {
  name        = "terraform-example-instance"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = "vpc-02b44b4072261e805"

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_vpc_security_group_ingress_rule" "instance_ipv4" {
  security_group_id = aws_security_group.instance.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.server_port
  ip_protocol       = "tcp"
  to_port           = var.server_port
}


variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
}