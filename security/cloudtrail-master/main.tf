provider "aws" {
    region = "${var.aws_region}"
    version = "~> 1.40"
}

terraform {
    # The configuration for this backend will be filled in by Terragrunt
    backend "s3" {}
    required_version = "~> 0.11.7"
}

module "cloudtrail_central" {
  source = "../../_sub/security/cloudtrail-config"
  s3_bucket = "${var.cloudtrail_central_s3_bucket}"
  trail_name = "org-audit"
  is_organization_trail = true
  cloudwatch_log_group_arn = "${data.terraform_remote_state.security-account.cloudwatch_cloudtrail_log_group_arn}"
  cloudwatch_cloudtrail_role_arn = "${data.terraform_remote_state.security-account.cloudwatch_cloudtrail_role_arn}"
}