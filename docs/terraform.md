# Usage with Terraform

Below follows an example of how you could use the binaries provided through the releases in this repository in Terraform. It was taken verbatim from https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest, bar the `package_url`.

I recommend you fork this repository and point the `package_url` there though, because of the obvious security issues with deploying precompiled 3rd party binaries to your infrastructure.


```tf
locals {
  # Change this url to your fork of this repository
  package_url = "https://github.com/branie-it/aws-psql-rotator-lambda/releases/download/0.0.0/lambda_function-3.8-0.0.0.zip"
  downloaded  = "psql_rotator_lambda_${md5(local.package_url)}.zip"
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

module "lambda_function_existing_package_from_remote_url" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "my-lambda-existing-package-local"
  description   = "My awesome lambda function"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  create_package         = false
  local_existing_package = data.null_data_source.psql_rotator_lambda.outputs["filename"]
}
```
