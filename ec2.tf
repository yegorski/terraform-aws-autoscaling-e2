data "aws_ami" "ami" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["${var.ami_filter}"]
  }
}

resource "aws_launch_template" "lt" {
  name = "${var.app_name}"

  image_id      = "${data.aws_ami.ami.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.ssh_key_name}"

  instance_initiated_shutdown_behavior = "terminate"

  iam_instance_profile {
    name = "${aws_iam_instance_profile.server.id}"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = "gp2"
      volume_size = "${var.volume_size}"
    }
  }

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = "${var.associate_public_ip_address}"
    delete_on_termination       = true

    security_groups = ["${aws_security_group.server.id}"]
  }

  tag_specifications {
    resource_type = "instance"

    tags = "${merge(
      map("Name", "${var.app_name}"),
      var.tags)
    }"
  }

  tag_specifications {
    resource_type = "volume"

    tags = "${merge(
      map("Name", "${var.app_name}"),
      var.tags)
    }"
  }

  tags = "${merge(
    map("Name", "${var.app_name}"),
    var.tags)
  }"
}

resource "aws_autoscaling_group" "server" {
  name = "${var.app_name}"

  health_check_type = "EC2"

  launch_template {
    id      = "${aws_launch_template.lt.id}"
    version = "$$Latest"
  }

  vpc_zone_identifier  = ["${var.subnet_ids}"]
  target_group_arns    = ["${aws_lb_target_group.tg.*.arn}"]
  termination_policies = ["OldestLaunchConfiguration", "OldestInstance"]

  min_size         = "0"
  desired_capacity = "1"
  max_size         = "1"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tags = [
    {
      "key"                 = "Name"
      "value"               = "${var.app_name}"
      "propagate_at_launch" = true
    },
  ]
}
