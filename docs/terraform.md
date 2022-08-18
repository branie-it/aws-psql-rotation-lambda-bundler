# Usage with Terraform

Below follows an example of how you could use the binaries provided through the releases in this repository in Terraform. A huge chunk of the code was taken from https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest.

I recommend you to fork this repository and point the `package_url` there though, because of the obvious security issues involved with deploying precompiled 3rd party binaries to your infrastructure.


```tf
locals {
  # Change this url to your fork of this repository
  package_url = "https://github.com/branie-it/aws-psql-rotator-lambda/releases/download/0.0.0/lambda_function-3.8-0.0.0.zip"
  downloaded  = "psql_rotator_lambda_${md5(local.package_url)}.zip"

  # Adapt these values to your situation
  account_id             = YOUR_AWS_ACCOUNT_ID
  secrets_manager_region = YOUR_SECRET_MANAGERS_REGION
}

resource "null_resource" "download_package" {
  triggers = {
    downloaded = local.downloaded
  }

  provisioner "local-exec" {
    command = "curl -L -o ${local.downloaded} ${local.package_url}"
  }
}

data "null_data_source" "psql_rotator_lambda" {
  inputs = {
    id       = null_resource.download_package.id
    filename = local.downloaded
  }
}

resource "aws_iam_policy" "AllowPSQLSecretsManagement" {
  name        = "AllowPSQLSecretsManagement"
  path        = "/"
  description = "Allow an entity to manage secrets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:CancelRotateSecret",
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:PutSecretValue",
          "secretsmanager:RotateSecret",
          "secretsmanager:UpdateSecret",
          "secretsmanager:UpdateSecretVersionStage",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:*:${local.account_id}:secret:*"
      },
      {
        Action = [
          "secretsmanager:GetRandomPassword",
          "secretsmanager:ListSecrets",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "PSQLRotatorLambdaRole" {
  name = "PSQLRotatorLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "edgelambda.amazonaws.com"
        }
      },
    ]
  })
}

locals {
  iam_psql_lambda_policies_arn = [
    aws_iam_policy.AllowPSQLSecretsManagement.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
}

resource "aws_iam_role_policy_attachment" "PSQLRotatorLambdaPoliciesAttach" {
  role = aws_iam_role.PSQLRotatorLambdaRole.name

  count      = length(local.iam_psql_lambda_policies_arn)
  policy_arn = local.iam_psql_lambda_policies_arn[count.index]
}

resource "aws_lambda_function" "PSQLRotatorLambda" {
  role = aws_iam_role.PSQLRotatorLambdaRole.arn

  function_name = "PSQLRotator"
  filename      = data.null_data_source.psql_rotator_lambda.outputs["filename"]

  description = "Rotates PSQL secrets"
  handler     = "lambda_function.lambda_handler"
  runtime     = "python3.8"

  environment {
    variables = {
      EXCLUDE_CHARACTERS       = ":/@\"'\\"
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${local.secrets_manager_region}.amazonaws.com"
    }
  }
}

resource "aws_lambda_permission" "AllowPermissionFromSecretsManager" {
  statement_id  = "AllowPermissionFromSecretsManager"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.PSQLRotatorLambda.function_name
  principal     = "secretsmanager.amazonaws.com"
}
```
