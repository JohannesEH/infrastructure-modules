resource "aws_s3_bucket" "container-registry" {
  bucket = "${var.s3_bucket}"
  tags = {
      "Managed by" = "Terraform"
  }

  force_destroy = true
}