variable "aws_lb_arn" {
  description = "ARN of your LoadBalance that you want to attach with WAF.."
  type        = string
}

variable waf_name {
  description = "Name prefix for all resources."
  type        = string
}