#!/usr/bin/env bash

# Copyright (c) Ely Deckers.
#
# This source code is licensed under the MPL-2.0 license found in the
# LICENSE file in the root directory of this source tree.

VERSION=0.0.0

echo "Running bundler version ${VERSION}"

echo "Changing working directory"
cd `dirname ${0}`/..
echo "Changed working directory (directory=`pwd`)"

echo "Nuking 'dist' directory"
rm -rf dist
echo "Nuked 'dist' directory"

echo "Creating 'dist'"
mkdir dist
echo "Created 'dist'"

echo "Retrieving lambda PSQL rotator source from AWS respository"
curl -s https://raw.githubusercontent.com/aws-samples/aws-secrets-manager-rotation-lambdas/master/SecretsManagerRDSPostgreSQLRotationSingleUser/lambda_function.py > dist/lambda_function.py
echo "Retrieved lambda PSQL rotator source from AWS respository"

echo "Installing all Python requirements in 'dist'"
pip install -r src/requirements.txt -t dist
echo "Installed all Python requirements in 'dist'"

echo "Changing workdir to 'dist'"
cd dist
echo "Changed workdir to 'dist'"

echo "Copying libpq.so from psycopg2_binary to 'dist'"
mv psycopg2_binary.libs/libpq*.so.5* libpq.so.5
echo "Copied libpq.so from psycopg2_binary to 'dist'"

echo "Copying all required dependencies for libpq.so to 'dist'"
mv psycopg2_binary.libs/* .
echo "Copied all required dependencies for libpq.so to 'dist'"

echo "Nuking all subdirectories of 'dist'"
find . -maxdepth 1 -mindepth 1 -type d -exec rm -rf '{}' \;
echo "Nuked all subdirectories of 'dist'"

echo "Building archive 'dist/lambda_function.zip"
zip -r lambda_function.zip .
echo "Built archive 'dist/lambda_function.zip"
