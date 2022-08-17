# PSql Secret Rotator Lambda bundler

[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)

The scripts in this repository bundles the [PSql Secret Rotator Lambda](https://github.com/aws-samples/aws-secrets-manager-rotation-lambdas/tree/master/SecretsManagerRDSPostgreSQLRotationMultiUser) provided by Amazon.

Seems simple enough, but it took me some time to figure out:
1. That some shared libraries are to be bundled with the Python code
2. Which libraries should be bundled
3. What is the simplest way to obtain them

## Problem solved

Now that you have a bundler you can adapt the code to use your own password generator for example - that is probably a bad idea, don't do that ;) 

## Requirements

- Python 3.7+ on the builder machine
- Same Python version on the Lambda

## Usage

### Shell

```bash
make build
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the  repository and the development workflow.

## Code of Conduct

[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## License

MPL-2.0
