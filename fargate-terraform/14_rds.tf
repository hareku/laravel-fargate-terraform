#####################################
# RDS Settings
#####################################
resource "aws_db_subnet_group" "this" {
  name       = "${var.app_name}"
  subnet_ids = ["${aws_subnet.rds_a.id}", "${aws_subnet.rds_c.id}", "${aws_subnet.rds_d.id}"]

  tags {
    Name = "${var.app_name}"
  }
}

resource "aws_rds_cluster" "this" {
  cluster_identifier   = "${var.app_name}-cluster"
  skip_final_snapshot  = true
  engine               = "aurora-mysql"
  db_subnet_group_name = "${aws_db_subnet_group.this.id}"

  availability_zones = [
    "${aws_subnet.rds_a.availability_zone}",
    "${aws_subnet.rds_c.availability_zone}",
    "${aws_subnet.rds_d.availability_zone}",
  ]

  vpc_security_group_ids          = ["${aws_security_group.rds.id}"]
  port                            = 3306
  backup_retention_period         = 1
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]
  snapshot_identifier             = "arn:aws:rds:${var.aws_region}:${var.aws_id}:snapshot:db-migrate-snapshot"
  preferred_backup_window         = "18:30-19:00"
  preferred_maintenance_window    = "wed:19:30-wed:20:00"
}

resource "aws_rds_cluster_instance" "this" {
  count = 1

  identifier          = "${var.app_name}-${count.index + 1}"
  cluster_identifier  = "${aws_rds_cluster.this.id}"
  engine              = "aurora-mysql"
  instance_class      = "db.t2.small"
  monitoring_interval = 60
  monitoring_role_arn = "arn:aws:iam::${var.aws_id}:role/rds-monitoring-role"
}
