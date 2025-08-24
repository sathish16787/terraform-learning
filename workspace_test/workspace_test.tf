resource "aws_instance" "example" {
  ami = "ami-08b138b7cf65145b1"
  instance_type = "t2.micro"
  subnet_id = "subnet-0b22adcab813d1daa"

  tags = {
    Name = "terraform-example"
  }
}


terraform {
backend "s3" {
bucket = "random-tf-test"
key = "workspaces-example/terraform.tfstate"
region = "ap-southeast-1"
dynamodb_table = "random-tf-state-locks"
encrypt = true
}
}