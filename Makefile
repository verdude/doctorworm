PROJECT = doctorworm
PROJECT_DESCRIPTION = I live like a worm
PROJECT_VERSION = 0.1.0

DEPS = cowboy
dep_cowboy_commit = 2.9.0

# Whitespace to be used when creating files from templates.
SP = 2

BUILD_DEPS += relx
include erlang.mk

.PHONY: fmt
FMT = _build/erlang-formatter-master/fmt.sh
$(FMT):
	mkdir -p _build/
	curl -f#SL 'https://codeload.github.com/fenollp/erlang-formatter/tar.gz/master' | tar xvz -C _build/

# Pick either this one to go through the whole project
fmt: TO_FMT ?= .
# Or this faster, incremental pass
#fmt: TO_FMT ?= $(shell git --no-pager diff --name-only HEAD origin/master -- '*.app.src' '*.config' '*.config.script' '*.erl' '*.escript' '*.hrl')

fmt: $(FMT)
	$(if $(TO_FMT), $(FMT) $(TO_FMT))
# Example:
#   TO_FMT='src/a.erl include/b/hrl' make fmt
