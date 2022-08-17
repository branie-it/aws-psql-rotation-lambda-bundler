.PHONY: build clean release

.DEFAULT_GOAL := help

help:
	@echo "Please use 'make <target>' where <target> is one of"
	@echo ""
	@echo "  build      build the lambda package"
	@echo "  clean      remove all temporary files"
	@echo "  release    build a release and publish it"
	@echo ""
	@echo "Check the Makefile to know exactly what each target is doing."

build:
	src/create-psql-rotator-lambda.sh

clean:
	src/bin/clean.sh

release:
	assets/release/release-all.sh

