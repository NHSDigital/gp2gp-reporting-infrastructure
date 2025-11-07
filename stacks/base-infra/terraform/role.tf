data "aws_ssm_parameter" "gocd_trusted_principal" {
  name = var.cross_account_admin_role_principal
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_ssm_parameter.gocd_trusted_principal.value]
    }
  }
}

resource "aws_iam_role" "cross_account_admin" {
  name               = "registrations-cross-account-admin"
  description        = "Role to assume from the common PRM account"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.cross_account_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}