#####################################
# ECS Cluster Settings
#####################################
resource "aws_ecs_cluster" "this" {
  name = "${var.app_name}-cluster"
}
