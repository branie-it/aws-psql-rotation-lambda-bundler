#!/usr/bin/env bash

# Copyright (c) Ely Deckers.
#
# This source code is licensed under the MPL-2.0 license found in the
# LICENSE file in the root directory of this source tree.

START_VERSION=${START_VERSION:-1.0.0}

function print_version_from_parts () {
  echo "${1}.${2}.${3}"
}

function retrieve_git_commit_messages () {
  git log --oneline --format='%h %s'
}

function normalize_commit_messages () {
  sed -rn 's/^([a-f0-9]+)\s+([a-z]+)\:\s+(.*)$/\1 \2 \3/p'
}

function filter_releases_from_normalized_commit_messages () {
  awk '{ if ($3 == "release" && $NF ~ "[0-9]+\.[0-9]+\.[0-9]+" ) { print } }'
}

function retrieve_last_release_message () {
  retrieve_git_commit_messages \
  | normalize_commit_messages \
  | filter_releases_from_normalized_commit_messages \
  | head -n1
}

function determine_version_significance_from_messages () {
  while read -r release_commit_message; do
    hash=`echo ${release_commit_message} | awk '{print $1}'`

    if git log --format="%B" ${hash}.. | grep -Eiq "breaking change(\([a-z0-9][a-z0-9]*\))?:"; then
      echo "major"
      return
    fi

    if git log --oneline --format="%s" ${hash}.. | grep -Eiq "feat(\([a-z0-9][a-z0-9]*\))?:"; then
      echo "minor"
      return
    fi

    if git log --oneline --format="%s" ${hash}.. | grep -Eiq "fix(\([a-z0-9][a-z0-9]*\))?:"; then
      echo "patch"
      return
    fi
  done

  echo "none"
}

function calculate_new_version_from_release_message () {
  read -r release_commit_message

  if [[ -z ${release_commit_message} ]]; then
    echo "0.0.0" "${START_VERSION}"
    return
  fi

  CURRENT_VERSION=`echo ${release_commit_message} | awk '{print $NF}'`

  if [[ ${START_VERSION} > ${CURRENT_VERSION} ]]; then
    CURRENT_VERSION=${START_VERSION}
  fi

  MAJOR_VERSION=`echo ${CURRENT_VERSION} | awk -F. '{print $1}'`
  MINOR_VERSION=`echo ${CURRENT_VERSION} | awk -F. '{print $2}'`
  PATCH_VERSION=`echo ${CURRENT_VERSION} | awk -F. '{print $3}'`

  NEW_VERSION_SIGNIFICANCE=`echo ${release_commit_message} | determine_version_significance_from_messages`

  if [[ ${NEW_VERSION_SIGNIFICANCE} == "major" ]]; then
    echo "${CURRENT_VERSION}" `print_version_from_parts $((${MAJOR_VERSION}+1)) 0 0`
    return
  fi

  if [[ ${NEW_VERSION_SIGNIFICANCE} == "minor" ]]; then
    echo "${CURRENT_VERSION}" `print_version_from_parts ${MAJOR_VERSION} $((${MINOR_VERSION}+1)) 0`
    return
  fi

  if [[ ${NEW_VERSION_SIGNIFICANCE} == "patch" ]]; then
    echo "${CURRENT_VERSION}" `print_version_from_parts ${MAJOR_VERSION} ${MINOR_VERSION} $((${PATCH_VERSION}+1))`
    return
  fi

  echo "${CURRENT_VERSION}" "${CURRENT_VERSION}"
}

retrieve_last_release_message \
| calculate_new_version_from_release_message
