
resource "aws_iam_role" "this" {
  for_each           = local.identity_providers
  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role[each.key].json
}

data "aws_iam_policy_document" "oidc_assume_role" {
  for_each = local.identity_providers
  version  = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${each.key}"]
    }

    dynamic "condition" {
      for_each = each.value._merged_attribute_condition
      content {
        test     = "StringEquals"
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "policy-arns" {
  for_each   = local.identity_providers
  role       = aws_iam_role.this[each.key].name
  policy_arn = each.value.policy_arn ? "" : local.default_policy_arn 
}

# Add actions missing from arn:aws:iam::aws:policy/ReadOnlyAccess
resource "aws_iam_policy" "additional-permissions" {
  for_each    = local.identity_providers
  name        = "${each.key}-policy"
  path        = "/"
  description = "A policy for extra permissions for ${each.key}"

  policy = data.aws_iam_policy_document.additional-permissions[each.key].json
  tags   = each.value.tags
}

resource "aws_iam_role_policy_attachment" "additional-permissions" {
  for_each   = local.identity_providers
  role       = aws_iam_role.this[each.key].name
  policy_arn = aws_iam_policy.additional-permissions[each.key].arn
}

data "aws_iam_policy_document" "additional-permissions" {
  for_each = local.identity_providers
  source_policy_documents = each.value.policy_jsons
}


