terraform {
    required_providers {
    aws = {
           source  = "hashicorp/aws"
           version = "~> 5.0"
        }
      }
    }

data "aws_ami" "ami" {
  most_recent      = true

  filter {
       name   = "name"
       values = ["Windows_Server-2019-English-Full-Base-*"]  
  }
  filter {
       name   = "virtualization-type"
       values = ["hvm"]  
  }
}

# ALB Security Group (Traffic Internet -> ALB)
resource "aws_security_group" "load-balancer" {
  name        = "load_balancer_security_group"
  description = "Controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance Security group (traffic ALB -> EC2, ssh -> EC2)
resource "aws_security_group" "ec2" {
  name        = "ec2_security_group"
  description = "Allows inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load-balancer.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "ssh_pubkey_file" {
  description = "Path to an SSH public key"
  default     = "~/.ssh/k0s.pub"
}

resource "aws_key_pair" "terraform-lab" {
  key_name   = "${var.ec2_instance_name}_key_pair"
  public_key = file(var.ssh_pubkey_file)
}

resource "aws_launch_configuration" "ec2" {
  name                        = "${var.ec2_instance_name}-instances-lc"
  image_id                    = data.aws_ami.ami.id
  instance_type               = "${var.ec2_instance_type}"
  security_groups             = [aws_security_group.ec2.id]
  key_name                    = aws_key_pair.terraform-lab.key_name
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = false
/*   user_data = <<-EOL
  #!/bin/bash -xe
  sudo yum update -y
  sudo yum -y install docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  sudo chmod 666 /var/run/docker.sock
  docker pull nginx
  docker tag nginx my-nginx
  docker run --rm --name nginx-server -d -p 80:80 -t my-nginx
  EOL */
}

resource "aws_lb" "terraform-lab" {
  name               = "${var.ec2_instance_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.load-balancer.id]
  subnets            = [var.public_subnet_id]
}

# Target group
resource "aws_alb_target_group" "default-target-group" {
  name     = "${var.ec2_instance_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 60
    matcher             = "200"
  }
}

resource "aws_autoscaling_group" "ec2-cluster" {
  name                 = "${var.ec2_instance_name}_auto_scaling_group"
  min_size             = var.autoscale_min
  max_size             = var.autoscale_max
  desired_capacity     = var.autoscale_desired
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.ec2.name
  vpc_zone_identifier  = [var.private_subnet_id]
  target_group_arns    = [aws_alb_target_group.default-target-group.arn]
}