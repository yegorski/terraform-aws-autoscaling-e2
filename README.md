# EC2 with Autoscaling and Load Balancing Terraform Module

Terraform module to create an AWS EC2 instance with autoscaling and load balancing.

The stack includes the following AWS resources:

1. Launch template that creates a server using the specified AMI filter.
1. EC2 autoscaling group that uses the launch template to spin up the server.
1. Load balancer that points dynamically to the EC2 server.

## Features

1. The server is recreated in the event that it is terminated.
1. Load balancing is dynamic and automatically points to the newly-created server.

## Usage

To create the server, you'll first need an AMI to use. The AMI can be a Linux OS with a sample Nginx config installed or a custom AMI with your application.

```terraform
module "autoscaling_ec2" {
  source = "git::https://github.com/yegorski/terraform-aws-autoscaling-e2.git?ref=master"

  region = "${var.region}"

  # Application
  app_name = "my_autoscaling_ec2"
  app_port = 80

  # EC2
  ami_owner     = "${var.ami_owner}"
  ami_filter    = "${var.ami_filter}"
  instance_type = "${var.instance_type}"
  ssh_ip        = "${var.ssh_ip}"
  ssh_key_name  = "${var.ssh_key_name}"

  # Network
  is_internal = "${var.is_internal}"
  subnet_ids  = "${var.subnet_ids}"
  vpc_id      = "${var.vpc_id}"

  tags = "${var.tags}"
}
```

## Inputs

| Name                        | Description                                                                          | Type   | Default                        | Required |
| --------------------------- | ------------------------------------------------------------------------------------ | ------ | ------------------------------ | :------: |
| region                      | The AWS region.                                                                      | string | `"us-east-1"`                  |   yes    |
| tags                        | A map of tags to apply to all AWS resources.                                         | map    |                                |   yes    |
| app_name                    | Used to name and tag AWS resources.                                                  | string |                                |   yes    |
| app_port                    | Port that the application is using on the server.                                    | string |                                |   yes    |
| ssh_key_name                | The name of the SSH key to use for the launched instances.                           | string |                                |   yes    |
| subnet_ids                  | Subnet IDs for server and load balancer.                                             | list   |                                |   yes    |
| vpc_id                      | The VPC ID to launch resources in.                                                   | string |                                |   yes    |
| ami_filter                  | Filter to obtain the Amazon Marketplace Image to use for the server.                 | string | `"amzn2-ami-hvm-*-x86_64-gp2"` |    no    |
| ami_owner                   | Owner of the AMI to use for the server. Used to look for the AMI on the marketplace. | string | `"amazon"`                     |    no    |
| associate_public_ip_address | Boolean to control whether to create a public IP address for the server.             | string | `false`                        |    no    |
| instance_type               | EC2 instance size.                                                                   | string | `t3.micro`                     |    no    |
| ssh_ip                      | Specify IP address to allow SSH access to the EC2 instace (such as your IP).         | string | `""` (no SSH access).          |    no    |
| volume_size                 | The size of the EBS volume for the server.                                           | string | `50` (GB).                     |    no    |
| alb_certificate_arn         | The ARN of the ALB certificate to attach to the load balancer.                       | string | `""` (no SSL).                 |    no    |
| is_internal                 | Boolean to control whether the load balancer is interal.                             | string | `true`                         |    no    |

## Outputs

| Name        | Description                                                                                          |
| ----------- | ---------------------------------------------------------------------------------------------------- |
| lb_dns_name | Load balancer URL.                                                                                   |
| lb_zone_id  | Load balancer DNS zone ID. Can be used to create a friedly DNS record to point to the load balancer. |
