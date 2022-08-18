# PSQL Secret Rotator Lambda bundler

[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)
[![Release to GitHub](https://github.com/branie-it/aws-psql-rotator-lambda/actions/workflows/release.yml/badge.svg)](https://github.com/branie-it/aws-psql-rotator-lambda/actions/workflows/release.yml)

The scripts in this repository bundle the [PSQL Secret Rotator Lambda](https://github.com/aws-samples/aws-secrets-manager-rotation-lambdas/blob/master/SecretsManagerRDSPostgreSQLRotationSingleUser/lambda_function.py) by Amazon with the required shared libraries.

Seems simple enough, but it took me some time to figure out
1. That the Lambda kept crashing on start, because some shared libraries must be bundled with the Python code
2. Exactly _which_ libraries must be bundled
3. What is the correct way to obtain these libraries for bundling

This bundler documents these findings and enables fully automated PSQL secret rotation management through means of Terraform for example.

## Requirements

- Python 3.7+ on the builder machine
- Same Python version on the Lambda AMI as used on the builder machine

## Usage

### Shell

```bash
make clean build
```

### Terraform

To illustrate a useful purpose of the bundler, I have included [a simple usage example for Terraform](docs/terraform.md).

## The problem

Amazon Secrets Manager allows you to [automatically rotate your secrets](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_how.html) on a scheduled interval by assigning them a rotator Lambda. There are a few examples built by Amazon readily available from the AWS Console, among them a PSQL Secret Rotator Lambda. So far so good, as this Lambda works just fine as-is. 

However, if you are anything like me, you want full control of what is deployed to your infrastructure and that means you want to decide exactly which version of each module is installed. You also want to do this automated through Terraform instead of manually clicking through the AWS Console.

When you simply upload the PSQL Rotator Lambda script from Amazon though, CloudWatch will ouput the error below.

>Unable to import module 'lambda_function': libpq.so.5: cannot open shared object file: No such file or directory

That is because the script depends on [PyGreSQL](https://github.com/PyGreSQL/PyGreSQL) - "a Python module [that] wraps the lower level C API library libpq to allow easy use of the powerful PostgreSQL features from Python" - which is not available on the Python Lambda AMI's. So you need to bundle it with your Lambda and that's where the code in this repository comes in.

It obtains the binaries that match the current Python version and CPU architecture by installing the PyGreSQL and the [psycopg2-binary](https://pypi.org/project/psycopg2-binary) packages through _pip_. These are then bundled into a zip archive, together with latest version of the Amazon PSQL Secret Rotator Lambda which is retrieved from the [master branch](https://github.com/aws-samples/aws-secrets-manager-rotation-lambdas/tree/master) of their repository.

## Applications

Some applications of this bundler include

1. Pinning specific versions of the PSQL Secret Rotator Lambda to your infrastructure
2. Adapting the code to your needs, e.g. to use your own password generator - that is probably a bad idea, don't do that :)

## Alternatives

[AWS Secrets Manager PSQL Rotation Lambda](https://github.com/0xSeb/aws_secrets_manager_psql_rotation_lambda) by [0xSeb](https://github.com/0xSeb).

Alters the original code by Amzon and bundles _psycopg2_.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the  repository and the development workflow.

## Code of Conduct

[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## License

MPL-2.0
