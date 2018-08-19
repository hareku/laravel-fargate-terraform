#####################################
# IAM Settings
#####################################
# ECS Tasks
data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks" {
  name               = "AWSECSTasksRole-For-${var.app_name}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_assume_role.json}"
}

data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = [
      "ecr:*",
      "logs:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ecs_tasks" {
  name   = "ECSTasksPolicy-For-${var.app_name}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.ecs_tasks.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_tasks" {
  role       = "${aws_iam_role.ecs_tasks.name}"
  policy_arn = "${aws_iam_policy.ecs_tasks.arn}"
}

# CodePipeline
data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "AWSCodePipelineRole-For-${var.app_name}"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline_assume_role.json}"
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    actions = [
      "*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "codepipeline" {
  name   = "CodePipelinePolicy-For-${var.app_name}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.codepipeline.json}"
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = "${aws_iam_role.codepipeline.name}"
  policy_arn = "${aws_iam_policy.codepipeline.arn}"
}

# CodeBuild
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "AWSCodeBuildRole-For-${var.app_name}"
  assume_role_policy = "${data.aws_iam_policy_document.codebuild_assume_role.json}"
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    actions = [
      "s3:*",
      "ecr:*",
      "logs:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "codebuild" {
  name   = "CodeBuildPolicy-For-${var.app_name}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = "${aws_iam_role.codebuild.name}"
  policy_arn = "${aws_iam_policy.codebuild.arn}"
}
