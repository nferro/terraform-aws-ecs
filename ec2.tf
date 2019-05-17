resource "aws_cloudwatch_log_group" "nginx" {
  name              = "nginx"
  retention_in_days = 1
}

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user-data.sh")}"

  vars {
    cluster_name = "${aws_ecs_cluster.cluster.name}"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_launch_configuration" "launch_config" {
  name_prefix                 = "${local.ec2_resources_name}-lc-"
  image_id                    = "${data.aws_ami.amazon_linux_ecs.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.ssh_key.id}"
  security_groups             = ["${aws_security_group.sg.id}"]
  associate_public_ip_address = true
  user_data                   = "${data.template_file.user_data.rendered}"

  iam_instance_profile = "${aws_iam_instance_profile.this.id}"

  depends_on = ["aws_iam_instance_profile.this"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "as_group" {
  launch_configuration = "${aws_launch_configuration.launch_config.id}"
  min_size             = "${var.as_group_min_size}"
  max_size             = "${var.as_group_max_size}"
  target_group_arns    = ["${aws_alb_target_group.nginx.arn}"]
  vpc_zone_identifier  = ["${aws_subnet.public.*.id}"]

  tag {
    key                 = "Name"
    value               = "${local.ec2_resources_name}-as"
    propagate_at_launch = true
  }
}