provider "aws" {} 
resource "aws_iam_openid_connect_provider" "default" {
  url = "https://token.actions.githubusercontent.com"
 
  client_id_list = [
    "sts.amazonaws.com",
  ]
 
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
  ]
}
 
resource "aws_iam_role" "github-oidc" {
  name = "github-oidc"
 
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow"
        Sid    = "RoleForGitHubActions",
        Principal = {
          "Federated" = "arn:aws:iam::XXXXXXXXXXX:oidc-provider/token.actions.githubusercontent.com"
        }
          "Condition": {
              "StringEquals": {
                  "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
              },
              "StringLike": {
                  "token.actions.githubusercontent.com:sub" = "repo:seifrajhi/demo-argo:*"
              }
          }
      },
    ]
  })
}
 
resource "aws_iam_role_policy" "github_actions_policy" {
  name = "github-actions-policy"
  role = aws_iam_role.github-oidc.id
 
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*",
           "ecr:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
