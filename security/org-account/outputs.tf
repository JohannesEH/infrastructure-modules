output "email" {
  value = "${module.org_account.email}"
}
output "id" {
  value = "${module.org_account.id}"
}

output "name" {
  value = "${module.org_account.name}"
}

output "org_role_name" {
  value = "${module.org_account.org_role_name}"
}

output "org_role_arn" {
  value = "${module.org_account.org_role_arn}"
}

output "cloudwatch_cloudtrail_log_group_arn" {
  value ="${module.cloudwatch_cloudtrail.log_group_arn}"
}

output "cloudwatch_cloudtrail_role_arn" {
  value = "${module.cloudwatch_cloudtrail.role_arn}"  
}