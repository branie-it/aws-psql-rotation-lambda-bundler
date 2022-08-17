#!/usr/bin/env bash

# Copyright (c) Ely Deckers.
#
# This source code is licensed under the MPL-2.0 license found in the
# LICENSE file in the root directory of this source tree.

VERSION_START=1.0.0 bin/semgen.sh | awk '{
  print "::set-output name=is_changed::" (($1 != $2) ? "true" : "false")
  print "::set-output name=previous_version::" $1
  print "::set-output name=version::" $2
}'
