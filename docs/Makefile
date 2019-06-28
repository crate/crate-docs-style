# Licensed to Crate (https://crate.io) under one or more contributor license
# agreements.  See the NOTICE file distributed with this work for additional
# information regarding copyright ownership.  Crate licenses this file to you
# under the Apache License, Version 2.0 (the "License"); you may not use this
# file except in compliance with the License.  You may obtain a copy of the
# License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.
#
# However, if you have executed another commercial license agreement with Crate
# these terms will supersede the license and you may use the software solely
# pursuant to the terms of the relevant commercial agreement.


.EXPORT_ALL_VARIABLES:

# `ROOT_RST_DIR` is where to look for RST files
ROOT_RST_DIR    := ..
ENV_DIR         := .env
ENV_BIN         := $(ENV_DIR)/bin
PYTHON          := python3.7
PIP             := $(ENV_BIN)/pip3.7
SPHINXBUILD     := $(ENV_BIN)/sphinx-build
SPHINXAUTOBUILD := $(ENV_BIN)/sphinx-autobuild
BUILD_DIR       := .build
SPHINX_ARGS     := . $(BUILD_DIR)
SPHINX_OPTS     := -W -n
AUTOBUILD_OPTS  := --ignore '*.' --ignore '*.lint'
STYLE_REPO      := https://github.com/crate/crate-docs-style.git
STYLE_VERSION   :=
STYLE_DIR       := .style
# `STYLE_DIR_ROOT` is the path to `STYLE_DIR` from `ROOT_RST_DIR`
STYLE_DIR_ROOT  := docs/$(STYLE_DIR)
STYLE_RULES     := $(STYLE_DIR_ROOT)/utils/rules.mk
STYLE_MAKE      := $(MAKE) -C $(ROOT_RST_DIR) -f $(STYLE_RULES)
FSWATCH         := fswatch

# Default target
.PHONY: help
help:
	@ printf 'Documentation Utils\n'
	@ echo
	@ printf 'Run `make <TARGET>`, where <TARGET> is one of:\n'
	@ echo
	@ printf '\033[36m  dev         \033[00m Run a Sphinx development server'
	@ printf                               ' that builds and lints the\n'
	@ printf '\033[36m              \033[00m documentation as you edit the'
	@ printf                               ' source files\n'
	@ echo
	@ printf '\033[36m  check       \033[00m Build, test, and lint the'
	@ printf                               ' documentation (run by CI)\n'
	@ echo
	@ printf '\033[36m  clean       \033[00m Clean up (e.g., remove lint'
	@ printf                               ' files)\n'
	@ echo
	@ printf '\033[36m  reset       \033[00m Reset the source\n'

$(SPHINXBUILD) $(SPHINXAUTOBUILD):
	$(PYTHON) -m venv $(ENV_DIR)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

ifeq ($(UNAME),Linux)
$(VALE):
	mkdir -p $(TOOLS_DIR)
	curl -L $(VALE_URL)/$(VALE_LINUX) -o $(TOOLS_DIR)/$(VALE_LINUX)
	cd $(TOOLS_DIR) && tar -xzf $(VALE_LINUX)
endif

ifeq ($(UNAME),Darwin)
$(VALE):
	mkdir -p $(TOOLS_DIR)
	curl -L $(VALE_URL)/$(VALE_MACOS) -o $(TOOLS_DIR)/$(VALE_MACOS)
	cd $(TOOLS_DIR) && tar -xzf $(VALE_MACOS)
endif

ifeq ($(STYLE_VERSION),)
# The documentation for the crate-docs-style project fakes an install of its
# own code so that it can test itself
$(STYLE_DIR):
	@ if test ! -d ../utils; then\
	    printf '\033[31mYou must set `STYLE_VERSION` to lint the '; \
	    printf 'documentation.\033[00m\n'; \
	    exit 1; \
	fi
	mkdir -p $@
	cp -R ../utils $@/utils
else
# The documentation for all other projects must install a versioned copy of the
# crate-docs-style project
$(STYLE_DIR):
	git clone --depth=1 -c advice.detachedHead=false \
	    --branch=$(STYLE_VERSION) $(STYLE_REPO) $(STYLE_DIR)
endif

.PHONY: autobuild
autobuild: $(SPHINXAUTOBUILD)
	$(SPHINXAUTOBUILD) $(SPHINX_ARGS) $(SPHINX_OPTS) $(AUTOBUILD_OPTS) $(O)

.PHONY: lint
lint: $(STYLE_DIR)
	$(STYLE_MAKE) lint

.PHONY: lint-watch
lint-watch: $(STYLE_DIR)
	@ $(FSWATCH) .build/sitemap.xml | while read num; do \
	    $(STYLE_MAKE) lint; \
	done || true

.PHONY: dev
dev:
	@ if test ! -x "`which $(FSWATCH)`"; then \
	    printf '\033[31mYou must have fswatch installed.\033[00m\n'; \
	    exit 1; \
	fi
	$(MAKE) -j autobuild lint-watch

.PHONY: check
check: html linkcheck lint

# Needed by `sphinx-build`
.PHONY: Makefile
Makefile:

# Route unknown targets to `sphinx-build`
%: $(SPHINXBUILD)
	$(SPHINXBUILD) -M $@ $(SPHINX_ARGS) $(SPHINX_OPTS) $(O)

.PHONY: clean
clean:
	@ if test -d $(STYLE_DIR); then \
	    $(STYLE_MAKE) clean; \
	fi

.PHONY: reset
reset: clean
	rm -rf $(ENV_DIR)
	rm -rf $(BUILD_DIR)
	rm -rf $(STYLE_DIR)