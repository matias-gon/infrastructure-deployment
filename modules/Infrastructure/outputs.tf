output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.ec2.alb_dns_name
}