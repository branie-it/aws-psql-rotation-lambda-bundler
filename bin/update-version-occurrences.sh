#!/usr/bin/env bash

# Copyright (c) Ely Deckers.
#
# This source code is licensed under the MPL-2.0 license found in the
# LICENSE file in the root directory of this source tree.

PREVIOUS_VERSION=${1}
NEW_VERSION=${2}

echo "Updating version occurrences from ${PREVIOUS_VERSION} to ${NEW_VERSION}"

sed -i "s/VERSION=${PREVIOUS_VERSION}/VERSION=${NEW_VERSION}/g" src/create-psql-rotator-lambda.sh
sed -i "/package_url\s=/ s/${PREVIOUS_VERSION}/${NEW_VERSION}/g" docs/terraform.md

echo "Updated version occurrences from ${PREVIOUS_VERSION} to ${NEW_VERSION}"
