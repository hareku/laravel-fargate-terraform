#####################################
# CloudWatch Logs for ECS Settings
#####################################
resource "aws_cloudwatch_log_group" "application" {
  name = "application/${var.app_name}"
}
