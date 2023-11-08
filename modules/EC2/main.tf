terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AMI search for Windows Server 2019 Base
data "aws_ami" "ami" {
  most_recent = true

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
resource "aws_security_group" "load_balancer_sg" {
  name        = "load-balancer-security-group-${var.environment}"
  description = "Controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "load-balancer-security-group-${var.environment}"
    Environment = var.environment
  }
}

# Instance Security group (traffic ALB -> EC2)
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group-${var.environment}"
  description = "Allows inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
    description     = "Allow HTTP inbound traffic from the ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "ec2-security-group-${var.environment}"
    Environment = var.environment
  }
}

# pub File for AWS Key Pair
locals {
  ssh_pubkey_file = var.pub_key_file
}

# Key Pair resource
resource "aws_key_pair" "ec2_windows_server_key" {
  key_name   = var.key_name
  public_key = file(local.ssh_pubkey_file)

  tags = {
    Environment = var.environment
  }
}

# Target group
resource "aws_alb_target_group" "default_target_group" {
  name     = "${var.ec2_instance_name}-tg-${var.environment}"
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

  tags = {
    Name        = "${var.ec2_instance_name}-tg-${var.environment}"
    Environment = var.environment
  }
}

# Application Load Balancer
resource "aws_lb" "application_load_balancer" {
  name               = "${var.ec2_instance_name}-alb-${var.environment}"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name        = "${var.ec2_instance_name}-alb-${var.environment}"
    Environment = var.environment
  }
}

# Application Load Balancer Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.default_target_group.arn
  }
}

# Launch Template
resource "aws_launch_template" "ec2" {
  name_prefix            = "${var.ec2_instance_name}-${var.environment}"
  image_id               = data.aws_ami.ami.id
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.ec2_windows_server_key.key_name

  iam_instance_profile {
    name = var.iam_instance_profile
  }


  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 30 # It does not allow define a size lesser than 30
      volume_type = "gp2"
    }
  }

  user_data = filebase64(var.user_data_file)

  tags = {
    Name        = "${var.ec2_instance_name}-${var.environment}"
    Environment = var.environment
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ec2_cluster" {
  name                = "${var.ec2_instance_name}-auto-scaling-group"
  min_size            = var.autoscale_min
  max_size            = var.autoscale_max
  desired_capacity    = var.autoscale_desired
  health_check_type   = "EC2"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_alb_target_group.default_target_group.arn]

  launch_template {
    id      = aws_launch_template.ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}