#####################################
# ALB Settings
#####################################
resource "aws_lb" "this" {
  name               = "${var.app_name}-alb"
  load_balancer_type = "application"
  internal           = false
  enable_http2       = true

  security_groups = ["${aws_security_group.elb.id}"]
  subnets         = ["${aws_subnet.elb_a.id}", "${aws_subnet.elb_c.id}"]

  access_logs {
    bucket  = "${aws_s3_bucket.elb_log.id}"
    prefix  = "ELBLog"
    enabled = true
  }

  tags {
    Name = "${var.app_name}-alb"
  }
}

#####################################
# ALB Target Settings
#####################################
resource "aws_lb_target_group" "http" {
  name        = "${var.app_name}-target-group"
  vpc_id      = "${aws_vpc.this.id}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  tags {
    Name = "${var.app_name}-target-group"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.this.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.http.arn}"
    type             = "forward"
  }
}

#####################################
# ALB Listener Settings
#####################################
resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.this.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "arn:aws:acm:${var.aws_region}:${var.aws_id}:certificate/12332523452348756238"

  default_action {
    target_group_arn = "${aws_lb_target_group.http.arn}"
    type             = "forward"
  }
}
