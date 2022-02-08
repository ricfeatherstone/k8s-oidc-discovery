resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_reader" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid = "EC2AssumeRole"
    effect  = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }

  dynamic "statement" {
    for_each = var.oidc_connect_providers
    content {
      sid = statement.value["name"]
      effect = "Allow"
      actions = [
        "sts:AssumeRoleWithWebIdentity",
      ]
      principals {
        type        = "Federated"
        identifiers = [
          format("arn:aws:iam::%s:oidc-provider/%s", data.aws_caller_identity.current.account_id,
            trimprefix(statement.value["issuer"], "https://"))
        ]
      }
      condition {
        test     = "StringLike"
        variable = format("%s:sub", trimprefix(statement.value["issuer"], "https://"))
        values   = [
          var.k8s_service_account,
        ]
      }
    }
  }
}
