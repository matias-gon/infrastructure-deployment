output alb_dns_name {
    description = "The DNS name of the ALB"
    value = "${aws_lb.application_load_balancer.dns_name}"
}