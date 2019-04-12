variable "aws_ecr_repo_name" {
  type = "string"
  default = "sunrise"
}

variable "logs_cloudwatch_retention" {
  type = "string"
  default = 365
}
