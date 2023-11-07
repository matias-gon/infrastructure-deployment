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
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_security_group"
  description = "Allows inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# pub File for AWS Key Pair
variable "ssh_pubkey_file" {
  description = "Path to an SSH public key"
  default     = "~/.ssh/key.pub"
}

# Key Pair resource
resource "aws_key_pair" "ec2_windows_server_key" {
  key_name   = "${var.ec2_instance_name}_key_pair"
  public_key = file(var.ssh_pubkey_file)
}

# Launch Configuration
resource "aws_launch_configuration" "ec2" {
  name                        = "${var.ec2_instance_name}-instances-lc"
  image_id                    = data.aws_ami.ami.id
  instance_type               = var.ec2_instance_type
  security_groups             = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.ec2_windows_server_key.key_name
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = false
  root_block_device {
    volume_size = 30 # It does not allow define a size lesser than 30
    volume_type = "gp2"
  }
  user_data = <<-EOL
  <powershell>
  # Install IIS
  Install-WindowsFeature -name Web-Server -IncludeManagementTools;
  </powershell>
  EOL
}

# Target group
resource "aws_alb_target_group" "default_target_group" {
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

# Application Load Balancer
resource "aws_lb" "application_load_balancer" {
  name               = "${var.ec2_instance_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = var.public_subnet_ids
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

# Auto Scaling Group
resource "aws_autoscaling_group" "ec2_cluster" {
  name                 = "${var.ec2_instance_name}_auto_scaling_group"
  min_size             = var.autoscale_min
  max_size             = var.autoscale_max
  desired_capacity     = var.autoscale_desired
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.ec2.name
  vpc_zone_identifier  = var.private_subnet_ids
  target_group_arns    = [aws_alb_target_group.default_target_group.arn]
}