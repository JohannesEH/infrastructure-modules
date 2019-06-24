resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.log_group_name}"
}

resource "aws_iam_role" "role" {
  name_prefix = "cloudwatch-cloudtrail-${var.log_group_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "cloudwatch-cloudtrail-${var.log_group_name}"
  path        = "/"
  description = "Policy to allow cloudtrail access to write to an S3 bucket"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailCreateLogStream20141101",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream"
            ],
            "Resource": [
                "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.log_group.name}:log-stream:*"
            ]
        },
        {
            "Sid": "AWSCloudTrailPutLogEvents20141101",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.log_group.name}:*"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_policy_attachment" "attachment" {
  name       = "cloudwatch-cloudtrail-${var.log_group_name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
  roles      = ["${aws_iam_role.role.name}"]
}
