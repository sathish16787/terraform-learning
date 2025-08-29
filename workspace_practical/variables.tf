variable "instance_type" {
  description = "Test instance"
  type = string
  default = "t2.medium"
}

variable "ami" {
  description = "Image id"
  type = string
  default = "ami-08b138b7cf65145b1"
}

variable "subnet_id" {
  description = "subnet id"
  type = string
  default = "subnet-0b22adcab813d1daa"
}
