#!/usr/bin/env bash

VERSION=1.0.0

echo "Running bundler version ${VERSION}"

echo "Nuking 'dist' directory"
rm -rf dist
echo "Nuked 'dist' directory"

echo "Creating 'dist' and changing workdir"
mkdir dist && cd dist
echo "Created 'dist' and changing workdir"

echo "Retrieving lambda PSql rotator source from AWS respository"
curl -s https://raw.githubusercontent.com/aws-samples/aws-secrets-manager-rotation-lambdas/master/SecretsManagerRDSPostgreSQLRotationSingleUser/lambda_function.py > lambda_function.py
echo "Retrieved lambda PSql rotator source from AWS respository"

echo "Installing all Python requirements in 'dist'"
pip install -r ../requirements.txt -t .
echo "Installed all Python requirements in 'dist'"

echo "Copying libpq.so from psycopg2_binary to 'dist'"
mv psycopg2_binary.libs/libpq*.so.5* libpq.so.5
echo "Copied libpq.so from psycopg2_binary to 'dist'"

echo "Copying all required dependencies for libpq.so to 'dist'"
readelf -d libpq.so.5 | grep 'NEEDED' | awk -F'[][]' '{print $2}' | xargs -I{} mv psycopg2_binary.libs/{} .
echo "Copied all required dependencies for libpq.so to 'dist'"

echo "Nuking all subdirectories of 'dist'"
find . -maxdepth 1 -mindepth 1 -type d -exec rm -rf '{}' \;
echo "Nuked all subdirectories of 'dist'"

echo "Building archive 'dist/lambda_function.zip"
zip -r lambda_function.zip .
echo "Built archive 'dist/lambda_function.zip"
