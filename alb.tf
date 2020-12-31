resource "aws_lb" "alb" {
  name            = "${var.app_name}"
  internal        = "${var.is_internal}"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${var.subnet_ids}"]

  tags = "${merge(
    map("Name", "${var.app_name}"),
    var.tags
  )}"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  count = "${var.alb_certificate_arn != "" ? 1 : 0}"

  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-2018-06"
  certificate_arn   = "${var.alb_certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  count = "${var.alb_certificate_arn != "" ? 1 : 0}"

  listener_arn = "${aws_lb_listener.http.arn}"

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.app_name}"
  port     = "${var.app_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path     = "/"
    port     = "${var.app_port}"
    protocol = "HTTP"
    matcher  = "200"
  }

  tags = "${merge(
    map("Name","${var.app_name}"),
    var.tags
  )}"
}
