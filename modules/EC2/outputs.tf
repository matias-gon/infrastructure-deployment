output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.application_load_balancer.dns_name
}

output "aws_lb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.application_load_balancer.arn
}