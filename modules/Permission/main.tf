terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Random number for S3 bucket creation
resource "random_id" "example" {
  byte_length = 8
}

# S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.region}-${var.environment}-${random_id.example.hex}"

  tags = {
    Name        = "${var.region}-${var.environment}-${random_id.example.hex}"
    Environment = "${var.environment}"
  }
}

# IAM polcity for S3 bucket access
resource "aws_iam_policy" "bucket_rw_access" {
  description = "bucket-rw-access-${var.region}-${var.environment}"
  name        = "bucket-rw-access-${var.region}-${var.environment}"
  policy = jsonencode(
    {
      Version = "2012-10-17"

      Statement = [
        {
          Action   = ["s3:ListBucket"]
          Effect   = "Allow"
          Resource = [aws_s3_bucket.bucket.arn]
        },
        {
          Action   = ["s3:GetObject", "s3:PutObject"]
          Effect   = "Allow"
          Resource = ["${aws_s3_bucket.bucket.arn}/*"]
        }
      ]
    }
  )
}

# IAM assume role for EC2 instance
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM role for EC2 instance
resource "aws_iam_role" "role_bucket_access" {
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  name               = "role-bucket-access-${var.region}-${var.environment}"

  inline_policy {
    name = "session-manager"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Action" : "ec2:*",
          "Effect" : "Allow",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "elasticloadbalancing:*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "cloudwatch:*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "autoscaling:*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:CreateServiceLinkedRole",
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "iam:AWSServiceName" : [
                "autoscaling.amazonaws.com",
                "ec2scheduled.amazonaws.com",
                "elasticloadbalancing.amazonaws.com",
                "spot.amazonaws.com",
                "spotfleet.amazonaws.com",
                "transitgateway.amazonaws.com"
              ]
            }
          }
        }
      ]
    })
  }
  tags = {
    Name = "role-bucket-access-${var.region}-${var.environment}"
  }
}

# IAM role policy attachment
resource "aws_iam_role_policy_attachment" "role_attachment" {
  role       = aws_iam_role.role_bucket_access.name
  policy_arn = aws_iam_policy.bucket_rw_access.arn
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "bucket-access-${var.region}-${var.environment}"
  role = aws_iam_role.role_bucket_access.name
}