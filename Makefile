PROJECT = dworm
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0

DEPS += cowboy
dep_cowboy_commit = 2.9.0

BUILD_DEPS += relx
include erlang.mk

release_gzip_path := /usr/local/src/dworm/_rel/dworm_release/dworm_release-1.tar.gz

.PHONY: docker-build
docker-build:
	docker build -t verdude/dworm --target=build .

.PHONY: copy-release
copy-release:
	docker run -v $$PWD:/opt -e LOCAL_USER_ID=$(shell id -u $$USER) --rm verdude/dworm cp $(release_gzip_path) /opt
