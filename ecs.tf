resource "aws_ecs_cluster" "cluster" {
  name = "${local.ec2_resources_name}-cluster"
}

resource "aws_ecs_task_definition" "nginx" {
  family                = "webserver"
  container_definitions = "${file("task-definitions/nginx.json")}"

  volume {
    name      = "nginx-storage"
    host_path = "/ecs/nginx-storage"
  }
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.nginx.arn}"
  desired_count   = 2
  depends_on      = ["aws_alb.nginx", "aws_iam_role.this"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.nginx.arn}"
    container_name   = "nginx"
    container_port   = 80
  }
}

