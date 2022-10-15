PROJECT = doctorworm
PROJECT_DESCRIPTION = I live like a worm
PROJECT_VERSION = 0.1.0

DEPS = cowboy
dep_cowboy_commit = 2.9.0

# Whitespace to be used when creating files from templates.
SP = 2

BUILD_DEPS += relx
include erlang.mk

release_dir := /usr/local/src/doctorworm/_rel/doctorworm_release
release_file := doctorworm_release-1.tar.gz
rel_gz := $(release_dir)/$(release_file)

.PHONY: fmt
FMT = _build/erlang-formatter-master/fmt.sh
$(FMT):
	mkdir -p _build/
	curl -fSL 'https://codeload.github.com/fenollp/erlang-formatter/tar.gz/master' | tar xvz -C _build/

fmt: TO_FMT ?= .

fmt: $(FMT)
	$(if $(TO_FMT), $(FMT) $(TO_FMT))

build:
	docker build -f Dockerfile --target=build -t verdude/doctorworm .

copy-release:
	docker run -v $$PWD:/opt -e LOCAL_USER_ID=$(shell id -u $$USER) --rm doctorworm cp $(rel_gz) /opt

build-runner:
	docker build -t verdude/run-doctorworm .
