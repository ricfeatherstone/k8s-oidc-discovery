resource "aws_iam_openid_connect_provider" "provider" {
  count = length(var.oidc_connect_providers)

  url             = element(var.oidc_connect_providers.*.issuer, count.index)
  client_id_list  = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [
    element(var.oidc_connect_providers.*.fingerprint, count.index),
  ]
}
