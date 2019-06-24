# CIS 1.5 - 1.10 IAM password requirements for console usage
resource "aws_iam_account_password_policy" "policy" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = "1"
}