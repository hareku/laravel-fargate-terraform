#####################################
# Security Group Settings
#####################################
# ELB
resource "aws_security_group" "elb" {
  name   = "${var.app_name}-elb"
  vpc_id = "${aws_vpc.this.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.app_name}-elb"
  }
}

# ECS
resource "aws_security_group" "ecs" {
  name   = "${var.app_name}-ecs"
  vpc_id = "${aws_vpc.this.id}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.app_name}-ecs"
  }
}

# ELB egress to ECS
resource "aws_security_group_rule" "elb_egress_to_ecs" {
  security_group_id        = "${aws_security_group.elb.id}"
  source_security_group_id = "${aws_security_group.ecs.id}"
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
}

# RDS
resource "aws_security_group" "rds" {
  name   = "${var.app_name}-rds"
  vpc_id = "${aws_vpc.this.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.app_name}-rds"
  }
}

# ElastiCache
resource "aws_security_group" "elasticache" {
  name   = "${var.app_name}-elasticache"
  vpc_id = "${aws_vpc.this.id}"

  ingress {
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.app_name}-elasticache"
  }
}
