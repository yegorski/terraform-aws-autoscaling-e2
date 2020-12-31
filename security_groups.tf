resource "aws_security_group" "alb" {
  name   = "${var.app_name}-alb"
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol    = "TCP"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "TCP"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(
    map("Name", "${var.app_name}-alb"),
    var.tags
  )}"
}

resource "aws_security_group" "server" {
  name = "${var.app_name}-server"

  vpc_id = "${var.vpc_id}"

  ingress {
    protocol        = "TCP"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  ingress {
    protocol    = "TCP"
    from_port   = "22"
    to_port     = "22"
    cidr_blocks = ["${var.ssh_ip}/32"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(
    map("Name", "${var.app_name}-server"),
    var.tags)}"
}
