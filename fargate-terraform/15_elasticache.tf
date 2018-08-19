#####################################
# ElastiCache Settings
#####################################
resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.app_name}"
  subnet_ids = ["${aws_subnet.elasticache_a.id}", "${aws_subnet.elasticache_c.id}"]
}

resource "aws_elasticache_cluster" "this" {
  cluster_id         = "${var.app_name}-cache"
  subnet_group_name  = "${aws_elasticache_subnet_group.this.name}"
  availability_zone  = "${aws_subnet.elasticache_a.availability_zone}"
  security_group_ids = ["${aws_security_group.elasticache.id}"]
  engine             = "memcached"
  node_type          = "cache.t2.micro"
  num_cache_nodes    = 1
  port               = 11211
}
