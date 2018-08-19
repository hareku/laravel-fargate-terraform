locals {
  az_a = "ap-northeast-1a"
  az_c = "ap-northeast-1c"
  az_d = "ap-northeast-1d"

  cidr_blocks {
    vpc           = "10.10.0.0/16"
    elb_a         = "10.10.1.0/24"
    elb_c         = "10.10.2.0/24"
    ecs_a         = "10.10.11.0/24"
    ecs_c         = "10.10.12.0/24"
    rds_a         = "10.10.21.0/24"
    rds_c         = "10.10.22.0/24"
    rds_d         = "10.10.23.0/24"
    elasticache_a = "10.10.31.0/24"
    elasticache_c = "10.10.32.0/24"
  }
}

#####################################
# VPC Settings
#####################################
resource "aws_vpc" "this" {
  cidr_block = "${lookup(local.cidr_blocks, "vpc")}"

  tags {
    Name = "${var.app_name}"
  }
}

#####################################
# Internet Gateway Settings
#####################################
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.this.id}"

  tags {
    Name = "${var.app_name}"
  }
}

#####################################
# Subnets Settings
#####################################
# ELB
resource "aws_subnet" "elb_a" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${lookup(local.cidr_blocks, "elb_a")}"
  availability_zone = "${local.az_a}"

  tags {
    Name = "${var.app_name}-elb-a"
  }
}

resource "aws_subnet" "elb_c" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${lookup(local.cidr_blocks, "elb_c")}"
  availability_zone = "${local.az_c}"

  tags {
    Name = "${var.app_name}-elb-c"
  }
}

# ECS
resource "aws_subnet" "ecs_a" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${lookup(local.cidr_blocks, "ecs_a")}"
  availability_zone = "${local.az_a}"

  tags {
    Name = "${var.app_name}-ecs-a"
  }
}

resource "aws_subnet" "ecs_c" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${lookup(local.cidr_blocks, "ecs_c")}"
  availability_zone = "${local.az_c}"

  tags {
    Name = "${var.app_name}-ecs-c"
  }
}

# RDS
resource "aws_subnet" "rds_a" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${lookup(local.cidr_blocks, "rds_a")}"
  availability_zone = "${local.az_a}"

  tags {
    Name = "${var.app_name}-rds-a"
  }
}

resource "aws_subnet" "rds_c" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${lookup(local.cidr_blocks, "rds_c")}"
  availability_zone = "${local.az_c}"

  tags {
    Name = "${var.app_name}-rds-c"
  }
}

resource "aws_subnet" "rds_d" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${lookup(local.cidr_blocks, "rds_d")}"
  availability_zone = "${local.az_d}"

  tags {
    Name = "${var.app_name}-rds-d"
  }
}

# ElastiCache
resource "aws_subnet" "elasticache_a" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${lookup(local.cidr_blocks, "elasticache_a")}"
  availability_zone = "${local.az_a}"

  tags {
    Name = "${var.app_name}-elasticache-a"
  }
}

resource "aws_subnet" "elasticache_c" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${lookup(local.cidr_blocks, "elasticache_c")}"
  availability_zone = "${local.az_c}"

  tags {
    Name = "${var.app_name}-elasticache-c"
  }
}

#####################################
# Routes Table Settings
#####################################
# Public
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.app_name}-public"
  }
}

#####################################
# Routes Table Association Settings
#####################################
# ELB
resource "aws_route_table_association" "elb_a" {
  subnet_id      = "${aws_subnet.elb_a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "elb_c" {
  subnet_id      = "${aws_subnet.elb_c.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# ECS
resource "aws_route_table_association" "ecs_a" {
  subnet_id      = "${aws_subnet.ecs_a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "ecs_c" {
  subnet_id      = "${aws_subnet.ecs_c.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# RDS
resource "aws_route_table_association" "rds_a" {
  subnet_id      = "${aws_subnet.rds_a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "rds_c" {
  subnet_id      = "${aws_subnet.rds_c.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "rds_d" {
  subnet_id      = "${aws_subnet.rds_d.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# ElastiCache
resource "aws_route_table_association" "elasticache_a" {
  subnet_id      = "${aws_subnet.elasticache_a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "elasticache_c" {
  subnet_id      = "${aws_subnet.elasticache_c.id}"
  route_table_id = "${aws_route_table.public.id}"
}
