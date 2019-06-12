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

GO              = go
GODIR           = .go
GOPATH          = $(CURDIR)/$(GODIR) # Must be absolute
RETOOLREPO      = github.com/twitchtv/retool
RETOOL          = $(GODIR)/bin/retool
TOOLSPATH       = .tools
RETOOLOPTS      = -base-dir=. -tool-dir=$(TOOLSPATH)
VALE            = $(TOOLSPATH)/bin/vale
LINT            = bin/lint
FSWATCH         = fswatch

# This file is designed so that it can be run from a any directory within a
# project, so the ROOTDIR (i.e., where to look for RST files) must be set
# explicitly
ifdef ROOTDIR
else
$(error ROOTDIR must be set)
endif

# Find all RST source files in the project (but skip the possible locations of
# third-party dependencies)
source_files := $(shell \
    cd '$(ROOTDIR)' && find . -not -path '*/\.*' -name '*\.rst' -type f)

# Generate targets
lint_targets = $(patsubst %,%.lint,$(source_files))
clean_targets = $(patsubst %,%.clean,$(lint_targets))

# Default target
.PHONY: help
help:
	@ printf 'This Makefile is not supposed to be run manually.\n'
	@ exit 1;

$(VALE):
	@ if test ! -x "`which $(GO)`"; then \
	    printf '\033[31mYou must have Go installed.\033[00m\n'; \
	    exit 1; \
	fi
	$(GO) get $(RETOOLREPO)
	@ printf '\033[33mThis might take a few minutes. '
	@ printf 'Please be patient!\033[00m\n'
	$(RETOOL) $(RETOOLOPTS) sync

# Lint an RST file and dump the output
%.rst.lint: %.rst
	$(LINT) '$<' '$@'

.PHONY: lint
lint: $(lint_targets)

.PHONY: lintdev
lintdev: lint
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
	    echo rm -f "$$filename"

.PHONY: clean
clean: $(clean_targets)

.PHONY: distclean
distclean: clean
	rm -rf $(GOPATH)
	rm -rf $(TOOLSPATH)
