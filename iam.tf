resource "aws_iam_role" "server" {
  name               = "${var.app_name}"
  assume_role_policy = "${data.aws_iam_policy_document.server.json}"
}

resource "aws_iam_instance_profile" "server" {
  name = "${var.app_name}"
  role = "${aws_iam_role.server.name}"
}

data "aws_iam_policy_document" "server" {
  statement {
    sid    = "AllowEC2Assume"
    effect = "Allow"

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
