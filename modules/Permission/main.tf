terraform {
    required_providers {
    aws = {
           source  = "hashicorp/aws"
           version = "~> 5.0"
        }
      }
    }

resource "random_id" "example" {
  byte_length = 8
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.region}-${var.enviroment}-${random_id.example.hex}"

  tags = {
    Name        = "${var.region}-${var.enviroment}-${random_id.example.hex}"
    Environment = "${var.enviroment}"
  }
}

resource "aws_iam_policy" "bucket-rw-access" {
  description = "bucket-rw-access-${var.region}-${var.enviroment}"
  name        = "bucket-rw-access-${var.region}-${var.enviroment}"
  policy      = jsonencode({
    "Version":"2012-10-17",
    "Statement":[
      {
        "Sid": "ListObjectsInBucket",
        "Effect": "Allow",
        "Action": ["s3:ListBucket"],
        "Resource": ["${aws_s3_bucket.bucket.arn}"]
      },
      {
        "Sid": "AllObjectActions",
        "Effect": "Allow",
        "Action": "s3:*Object",
        "Resource": ["${aws_s3_bucket.bucket.arn}/*"]
      }
    ]
  })
}

 resource "aws_iam_role" "role-bucket-access" {
  assume_role_policy = aws_iam_policy.bucket-rw-access.policy
  name               = "role-bucket-access-${var.region}-${var.enviroment}"
  tags = {
    Name = "role-bucket-access-${var.region}-${var.enviroment}"
  }
}

resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name  = "bucket-access-${var.region}-${var.enviroment}"
  role  = aws_iam_role.role-bucket-access.name
}