#####################################
# ECS Service Auto Scaling Settings
#####################################
resource "aws_cloudwatch_metric_alarm" "service_sacle_out_alerm" {
  alarm_name          = "${var.app_name}-ECSService-CPU-Utilization-High-70"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"

  dimensions {
    ClusterName = "${aws_ecs_cluster.this.name}"
    ServiceName = "${aws_ecs_service.this.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.scale_out.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "service_sacle_in_alerm" {
  alarm_name          = "${var.app_name}-ECSService-CPU-Utilization-Low-15"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "15"

  dimensions {
    ClusterName = "${aws_ecs_cluster.this.name}"
    ServiceName = "${aws_ecs_service.this.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.scale_in.arn}"]
}

resource "aws_appautoscaling_target" "ecs_service_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "arn:aws:iam::${var.aws_id}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
  min_capacity       = 1
  max_capacity       = 8
}

resource "aws_appautoscaling_policy" "scale_out" {
  name               = "scale-out"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_service_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.ecs_service_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.ecs_service_target"]
}

resource "aws_appautoscaling_policy" "scale_in" {
  name               = "scale-in"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_service_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.ecs_service_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.ecs_service_target"]
}
