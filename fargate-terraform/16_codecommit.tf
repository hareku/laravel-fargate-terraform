# #####################################
# # CodeCommit Settings
# #####################################
resource "aws_codecommit_repository" "application" {
  repository_name = "${var.app_name}-application"
}

resource "aws_codecommit_repository" "php_fpm_base" {
  repository_name = "${var.app_name}-php-fpm-base"
}
