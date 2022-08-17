# Copyright (c) Ely Deckers.
#
# This source code is licensed under the MPL-2.0 license found in the
# LICENSE file in the root directory of this source tree.

.PHONY: clean release

SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

.DEFAULT_GOAL := help

help:
	@echo "Please use 'make <target>' where <target> is one of"
	@echo ""
	@echo "  build      build the lambda package"
	@echo "  clean      nuke 'dist'"
	@echo ""
	@echo "Check the Makefile to know exactly what each target is doing."

dist:
	src/create-psql-rotator-lambda.sh

build: dist

clean:
	rm -rf dist
