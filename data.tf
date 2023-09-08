data "aws_caller_identity" "current" {}

data "tls_certificate" "issuer" {
  for_each = { for k, v in local.identity_providers : v.issuer => v }
  url      = each.value.issuer_uri
}

