
resource "aws_db_instance" "example" {
identifier_prefix = "terraform-up-and-running"
engine = "mysql"
allocated_storage = 10
instance_class = "db.t3.micro"
skip_final_snapshot = true
db_name = "example_database"
username = var.db_username
password = var.db_password
vpc_security_group_ids = ["sg-07d8adfc9339591b5"]
db_subnet_group_name    = aws_db_subnet_group.example.name
}

resource "aws_db_subnet_group" "example" {
  name       = "example-subnet-group"
  subnet_ids = data.aws_subnets.k8s_vpc.ids

  tags = {
    Name = "example-subnet-group"
  }
}


data "aws_vpc" "k8s_vpc" {
  filter {
    name   = "tag:Name"
    values = ["k8s-vpc"]
  }
}


data "aws_subnets" "k8s_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.k8s_vpc.id]
  }
}
