provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    assume_role {
        role_arn = "${var.assume_role_arn}"
    }
}

terraform {
    # The configuration for this backend will be filled in by Terragrunt
    backend "s3" {}
    required_version = "~> 0.11.7"
}

resource "aws_organizations_account" "dfds" {
    #Generate an organizational account based on the input from a tfvars file.
    name                       = "${var.aws_account_name}"
    email                      = "aws.${replace(var.aws_account_name, "dfds-", "")}@${var.email_domain}"
    iam_user_access_to_billing = "ALLOW"
    role_name                  = "${var.aws_org_rolename}"
}