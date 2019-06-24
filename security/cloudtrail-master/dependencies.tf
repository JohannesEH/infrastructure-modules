data "terraform_remote_state" "security-account" {
  backend = "s3"

  config {
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "_global/org-account/security/terraform.tfstate"
    region = "${var.terraform_state_region}"
  }
}