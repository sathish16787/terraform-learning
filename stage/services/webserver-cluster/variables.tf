variable "image_id" {
  description = "Image id"
  type = string
  default = "ami-08b138b7cf65145b1"
}

variable "instance_type" {
  description = "Instance type"
  type = string
  default = "t2.micro"
}


variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 80
}