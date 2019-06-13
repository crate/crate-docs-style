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

ENV_DIR      := .env
ENV_BIN      := $(ENV_DIR)/bin
PYTHON       := python3.7
PIP          := $(ENV_BIN)/pip
RST2HTML     := $(ENV_BIN)/rst2html.py
PATH         := $(ENV_BIN):$(PATH) # Put rst2html on the PATH for Vale
VALE_VERSION := 1.4.2
VALE_URL     := https://github.com/errata-ai/vale/releases/download
VALE_URL     := $(VALE_URL)/v$(VALE_VERSION)
VALE_LINUX   := vale_$(VALE_VERSION)_Linux_64-bit.tar.gz
VALE_MACOS   := vale_$(VALE_VERSION)_macOS_64-bit.tar.gz
VALE_WIN     := vale_$(VALE_VERSION)_Windows_64-bit.tar.gz
TOOLS_DIR    := .tools
VALE         := $(TOOLS_DIR)/vale
VALE_OPTS    := --config=$(CURDIR)_vale.ini
LINT         := bin/lint
FSWATCH      := fswatch

# This file is designed so that it can be run from a any directory within a
# project, so the ROOTDIR (i.e., where to look for RST files) must be set
# explicitly
ifdef ROOTDIR
else
$(error ROOTDIR must be set)
endif

# Figure out the OS
ifeq ($(findstring ;,$(PATH)),;)
    # Windows, but not POSIX environment`
else
    UNAME := $(shell uname 2>/dev/null || echo Unknown)
    UNAME := $(patsubst CYGWIN%,Windows,$(UNAME))
    UNAME := $(patsubst MSYS%,Windows,$(UNAME))
    UNAME := $(patsubst MINGW%,Windows,$(UNAME))
endif

# Find all RST source files in the project (but skip the possible locations of
# third-party dependencies)
source_files := $(shell \
    cd '$(ROOTDIR)' && find . -not -path '*/\.*' -name '*\.rst' -type f)

# Generate targets
lint_targets := $(patsubst %,%.lint,$(source_files))
clean_targets := $(patsubst %,%.clean,$(lint_targets))

# Default target
.PHONY: help
help:
	@ printf 'This Makefile is not supposed to be run manually.\n'
	@ exit 1;

$(RST2HTML):
	'$(PYTHON)' -m venv '$(ENV_DIR)'
	'$(PIP)' install --upgrade pip
	'$(PIP)' install -r 'requirements.txt'

$(TOOLS_DIR):
	mkdir $(TOOLS_DIR)

ifeq ($(UNAME),Linux)
$(VALE): $(TOOLS_DIR)
	curl -L $(VALE_URL)/$(VALE_LINUX) -o $(TOOLS_DIR)/$(VALE_LINUX)
	cd $(TOOLS_DIR) && tar -xzf $(VALE_LINUX)
endif

ifeq ($(UNAME),Darwin)
$(VALE): $(TOOLS_DIR)
	curl -L $(VALE_URL)/$(VALE_MACOS) -o $(TOOLS_DIR)/$(VALE_MACOS)
	cd $(TOOLS_DIR) && tar -xzf $(VALE_MACOS)
endif

.PHONY: vale
vale: $(RST2HTML) $(VALE)
	@ if test ! -x $(VALE); then \
	    printf 'No rules to install Vale on your operating system.\n'; \
	    exit 1; \
	fi

.PHONY: tools
tools: vale

# Lint an RST file and dump the output
%.rst.lint: %.rst
	$(LINT) '$<' '$@'

.PHONY: lint
lint: tools $(lint_targets)

.PHONY: lint-watch
lint-watch: lint
	@ if test ! -x "`which $(FSWATCH)`"; then \
	    printf '\033[31mYou must have fswatch installed.\033[00m\n'; \
	    exit 1; \
	fi
	@ printf '\033[33mWatching for changes...\033[00m\n'
	@ $(FSWATCH) -0 $(source_files) | xargs -0 -I {} $(LINT) {}

# Using targets for cleaning means we don't have to loop over the generated
# list of unescaped filenames
%.clean:
	@ # Fake the output so it's more readable
	@ filename=`echo $@ | sed s,.clean$$,,` && \
	    rm -f "$$filename" && \
	    printf "rm -f $$filename\n"

.PHONY: clean
clean: $(clean_targets)

.PHONY: cleantools
clean-all: clean
	rm -rf $(ENV_DIR)
	rm -rf $(TOOLS_DIR)
