variable "name" {}

variable "region" {
  default = "eu-west-2"
}
variable "oidc_connect_providers" {
  type = list(object({
    name = string
    issuer = string
    fingerprint = string
  }))
  default = [
    {
      name: "aws"
      issuer: "REPLACE_ME"
      fingerprint: "REPLACE_ME"
    },
    {
      name: "gcp"
      issuer: "REPLACE_ME"
      fingerprint: "REPLACE_ME"
    },
    {
      name: "azure"
      issuer: "REPLACE_ME"
      fingerprint: "REPLACE_ME"
    },
  ]
}
variable "k8s_service_account" {
  default = "system:serviceaccount:default:oidc-discovery-demo"
}
