resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
      Name = "${local.ec2_resources_name}-vpc"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${local.ec2_resources_name}-ig"
  }
}

resource "aws_route" "route" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gateway.id}"
}

resource "aws_subnet" "public" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags {
    Name = "${local.ec2_resources_name}-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_alb" "nginx" {
  name               = "${local.ec2_resources_name}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.public.*.id}"]
  security_groups    = ["${aws_security_group.sg.id}"]

  tags {
      Environment = "${terraform.workspace}"
  }
}

resource "aws_alb_target_group" "nginx" {
  name     = "${local.ec2_resources_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.nginx.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.nginx.arn}"
    type             = "forward"
  }
}

resource "aws_security_group" "sg" {
  name        = "${local.ec2_resources_name}-sg"
  description = "Free for all"
  vpc_id      = "${aws_vpc.vpc.id}"

  # Allow outbound internet access.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${local.ec2_resources_name}-sg"
  }
} 