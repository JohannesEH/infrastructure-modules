
output "log_group_arn" {
  value = "${aws_cloudwatch_log_group.log_group.arn}"
}

output "role_arn" {
  value = "${aws_iam_role.role.arn}"
}