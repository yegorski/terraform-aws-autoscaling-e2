output "lb_dns_name" {
  value = "${aws_lb.alb.dns_name}"
}

output "lb_zone_id" {
  value = "${aws_lb.alb.zone_id}"
}
