#####################################
# ECR Settings
#####################################
resource "aws_ecr_repository" "nginx" {
  name = "${var.app_name}-nginx"
}

resource "aws_ecr_repository" "php_fpm" {
  name = "${var.app_name}-php-fpm"
}

resource "aws_ecr_repository" "php_fpm_base" {
  name = "${var.app_name}-php-fpm-base"
}

#####################################
# ECR Lifecycle Policy Settings
#####################################
locals {
  lifecycle_policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 10,
        "description": "Expire images count more than 5",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 5
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}

resource "aws_ecr_lifecycle_policy" "nginx" {
  repository = "${aws_ecr_repository.nginx.name}"

  policy = "${local.lifecycle_policy}"
}

resource "aws_ecr_lifecycle_policy" "php_fpm" {
  repository = "${aws_ecr_repository.php_fpm.name}"

  policy = "${local.lifecycle_policy}"
}

resource "aws_ecr_lifecycle_policy" "php_fpm_base" {
  repository = "${aws_ecr_repository.php_fpm_base.name}"

  policy = "${local.lifecycle_policy}"
}
