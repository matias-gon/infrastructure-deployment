output "arn" {
  description = "The ARN of waf"
  value = aws_wafv2_web_acl.WafWebAcl.arn
}