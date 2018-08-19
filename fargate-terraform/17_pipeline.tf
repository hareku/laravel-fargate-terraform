#####################################
# S3 for CodePipeline Settings
#####################################
resource "aws_s3_bucket" "codepipeline" {
  bucket        = "${var.app_name}-codepipeline"
  acl           = "private"
  force_destroy = true
}

#####################################
# CodeBuild Settings
#####################################
resource "aws_codebuild_project" "application" {
  name          = "${var.app_name}-application"
  build_timeout = "10"
  service_role  = "${aws_iam_role.codebuild.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type = "CODEPIPELINE"
  }
}

resource "aws_codebuild_project" "php_fpm_base" {
  name          = "${var.app_name}-php-fpm-base"
  build_timeout = "10"
  service_role  = "${aws_iam_role.codebuild.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type = "CODEPIPELINE"
  }
}

#####################################
# CodePipeline Settings
#####################################
resource "aws_codepipeline" "application" {
  name     = "${var.app_name}-application"
  role_arn = "${aws_iam_role.codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["application-source"]

      configuration {
        RepositoryName = "${var.app_name}-application"
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["application-source"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "${var.app_name}-application"
      }
    }
  }

  stage {
    name = "Production"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration {
        ClusterName = "${aws_ecs_cluster.this.name}"
        ServiceName = "${aws_ecs_service.this.name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

resource "aws_codepipeline" "php_fpm_base" {
  name     = "${var.app_name}-php-fpm-base"
  role_arn = "${aws_iam_role.codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["application-source"]

      configuration {
        RepositoryName = "${var.app_name}-php-fpm-base"
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["application-source"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "${var.app_name}-php-fpm-base"
      }
    }
  }
}
