resource "aws_launch_template" "example" {
  name_prefix = "terraform-example-"
  image_id = var.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id] 

user_data = base64encode(templatefile("user-data.sh",{
  server_port = var.server_port
  db_address = data.terraform_remote_state.db.outputs.address
  db_port = data.terraform_remote_state.db.outputs.port
}))
  
  lifecycle {
    create_before_destroy = true  
  }
}

resource "aws_autoscaling_group" "example" {
  vpc_zone_identifier = data.aws_subnets.k8s_vpc.ids
  target_group_arns   = [aws_lb_target_group.asg.arn]
  health_check_type   = "ELB"

  desired_capacity = 2
  min_size         = 2
  max_size         = 5

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  name        = "terraform-example-instance"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.k8s_vpc.id

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

resource "aws_lb" "example" {
  name = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.k8s_vpc.ids
  security_groups    = [aws_security_group.alb.id]
  #subnets = [element(data.aws_subnets.k8s_vpc.ids, 0), element(data.aws_subnets.k8s_vpc.ids, 1)]
  #security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
    }

      lifecycle {
    prevent_destroy = false
  }
  }


resource "aws_security_group" "alb" {
  name        = "terraform-example-alb"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.k8s_vpc.id

  tags = {
    Name = "allow_tls_alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_ipv4" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_lb_target_group" "asg" {
name = "terraform-asg-example"
port = var.server_port
protocol = "HTTP"
vpc_id = data.aws_vpc.k8s_vpc.id
health_check {
  path = "/"
  protocol = "HTTP"
  matcher = "200"
  interval = 15
  timeout = 3
  healthy_threshold = 2
  unhealthy_threshold = 2
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

    filter {
    name   = "tag:Name"
    values = ["k8s-vpc-public-0", "k8s-vpc-public-1"]
  }
}


data "terraform_remote_state" "db" {
backend = "s3"
config = {
bucket = "random-tf-test"
key = "stage/data-store/mysql/terraform.tfstate"
region = "ap-southeast-1"
}
}