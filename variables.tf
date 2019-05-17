variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {
  default = "us-east-1"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "as_group_min_size" {
  default = 2
}

variable "as_group_max_size" {
  default = 10
}

variable "instance_type" {
  default = "t2.micro"
}

locals {
  name        = "nginx3"
  environment = "${terraform.workspace}"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"
}