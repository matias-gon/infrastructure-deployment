output "alb_dns_name_au_production" {
  description = "The DNS name of the ALB"
  value       = module.infrastructure_au["production"].alb_dns_name
}

output "alb_dns_name_au_testing" {
  description = "The DNS name of the ALB"
  value       = module.infrastructure_au["testing"].alb_dns_name
}

output "alb_dns_name_uk_production" {
  description = "The DNS name of the ALB"
  value       = module.infrastructure_uk["production"].alb_dns_name
}

output "alb_dns_name_uk_testing" {
  description = "The DNS name of the ALB"
  value       = module.infrastructure_uk["testing"].alb_dns_name
}

output "alb_dns_name_us_production" {
  description = "The DNS name of the ALB"
  value       = module.infrastructure_us["production"].alb_dns_name
}

output "alb_dns_name_us_testing" {
  description = "The DNS name of the ALB"
  value       = module.infrastructure_us["testing"].alb_dns_name
}