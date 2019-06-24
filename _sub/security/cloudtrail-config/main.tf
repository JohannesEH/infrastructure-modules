resource "aws_cloudtrail" "cloudtrail" {
  count                         = "${var.s3_bucket != "" ? 1 : 0}"
  name                          = "${var.trail_name}"
  s3_bucket_name                = "${var.s3_bucket}"
  is_multi_region_trail         = true
  is_organization_trail         = "${var.is_organization_trail}"
  include_global_service_events = true
  enable_logging                = true
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = "${var.cloudwatch_log_group_arn}"
  cloud_watch_logs_role_arn     = "${var.cloudwatch_cloudtrail_role_arn}"
}