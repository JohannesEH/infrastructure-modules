# ------------------------------------------------------------------------------
# DEFINE IAM POLICIES
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# GENERATE ROUTE 53 ZONE POLICY
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "create_route53_zone" {
    statement {
        sid       = "Route53CreateZone"
        actions   = ["CreateHostedZone"]
        resources = ["*"]
        effect    = "Allow"
    }
}