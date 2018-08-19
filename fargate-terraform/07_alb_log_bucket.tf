#####################################
# S3 Settings
#####################################
resource "aws_s3_bucket" "elb_log" {
  bucket        = "${var.app_name}-elb-log"
  force_destroy = true

  tags {
    Name = "${var.app_name}-elb-log"
  }
}

data "aws_elb_service_account" "elb_log" {}

data "aws_iam_policy_document" "elb_log" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.elb_log.id}/ELBLog/AWSLogs/${var.aws_id}/*",
    ]

    principals = {
      type = "AWS"

      identifiers = [
        "${data.aws_elb_service_account.elb_log.id}",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "elb_log" {
  bucket = "${aws_s3_bucket.elb_log.id}"
  policy = "${data.aws_iam_policy_document.elb_log.json}"
}
