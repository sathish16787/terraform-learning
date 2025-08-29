output "instance" {
value = aws_instance.example.public_ip
description = "The domain name of the load balancer"
}