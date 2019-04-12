#
# ECR - Docker Repo for Application
#

resource "aws_ecr_repository" "main" {
  name = "${var.aws_ecr_repo_name}"
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = "${aws_ecr_repository.repo.name}"
  policy     = "${file("ecr-lifecycle-policy.json")}"
}

#
# ECS - Staging
#

resource "aws_ecs_cluster" "staging" {
  name = "sunrise-staging"

  lifecycle {
    create_before_destroy = true
  }
}

module "ecs_service_staging" {
  source = "../../modules/aws-ecs-service"

  name        = "sunrise"
  environment = "staging"

  ecs_cluster_arn               = "${aws_ecs_cluster.staging.arn}"
  ecs_vpc_id                    = "${module.vpc.vpc_id}"
  ecs_subnet_ids                = "${module.vpc.private_subnets}"
  tasks_desired_count           = 2
  tasks_minimum_healthy_percent = 50
  tasks_maximum_percent         = 200

  associate_alb      = true
  alb_security_group = "${module.security_group.id}"
  lb_target_group   = "${module.target_group.id}"
}

#
# ECS - Prod
#

resource "aws_ecs_cluster" "prod" {
  name = "sunrise-prod"

  lifecycle {
    create_before_destroy = true
  }
}

module "ecs_service_prod" {
  source = "../../modules/aws-ecs-service"

  name        = "sunrise"
  environment = "prod"

  ecs_cluster_arn               = "${aws_ecs_cluster.prod.arn}"
  ecs_vpc_id                    = "${module.vpc.vpc_id}"
  ecs_subnet_ids                = "${module.vpc.private_subnets}"
  tasks_desired_count           = 2
  tasks_minimum_healthy_percent = 50
  tasks_maximum_percent         = 200

  associate_alb      = true
  alb_security_group = "${module.security_group.id}"
  lb_target_group   = "${module.target_group.id}"
}
