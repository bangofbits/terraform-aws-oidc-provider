resource "aws_iam_openid_connect_provider" "this" {
  for_each        = { for k, v in local.identity_providers : v.issuer => v }
  url             = each.value.issuer_uri
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = distinc(data.tls_certificate.issuer[each.key].certificates[*].sha1_fingerprint, each.value.known_fingerprints)
  tags            = each.value.tags
}
