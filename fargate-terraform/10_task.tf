#####################################
# ECS Tasks Settings
#####################################
# main
data "template_file" "main" {
  template = "${file("task/main.json")}"

  vars {
    app_name          = "${var.app_name}"
    aws_region        = "${var.aws_region}"
    rp_image_url      = "${aws_ecr_repository.nginx.repository_url}"
    php_fpm_image_url = "${aws_ecr_repository.php_fpm.repository_url}"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.app_name}-main"
  container_definitions    = "${data.template_file.main.rendered}"
  execution_role_arn       = "${aws_iam_role.ecs_tasks.arn}"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  depends_on = [
    "aws_cloudwatch_log_group.application",
  ]
}

# db migration
data "template_file" "db_migration" {
  template = "${file("task/db-migration.json")}"

  vars {
    app_name          = "${var.app_name}"
    aws_region        = "${var.aws_region}"
    php_fpm_image_url = "${aws_ecr_repository.php_fpm.repository_url}"
  }
}

resource "aws_ecs_task_definition" "db_migration" {
  family                   = "${var.app_name}-db-migration"
  container_definitions    = "${data.template_file.db_migration.rendered}"
  execution_role_arn       = "${aws_iam_role.ecs_tasks.arn}"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  depends_on = [
    "aws_cloudwatch_log_group.application",
  ]
}
