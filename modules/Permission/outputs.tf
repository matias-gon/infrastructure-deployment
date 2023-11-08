output "aws_iam_instance_profile_name" {
  description = "The ID of the instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}