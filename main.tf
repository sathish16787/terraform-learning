provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "example" {
  ami = "ami-08b138b7cf65145b1"
  instance_type = "t2.micro"
  subnet_id = "subnet-0b22adcab813d1daa"

  tags = {
    Name = "terraform-example"
  }
}