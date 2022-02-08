output "aws_iam_role_arn" {
  sensitive = true
  value = aws_iam_role.role.arn
}
