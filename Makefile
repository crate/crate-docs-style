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

# ROOTDIR must be set in the parent Makefile

STYLEDIR        = $(abspath $(CURDIR))
GO              = go
GOPATH          = $(STYLEDIR)/.go
RETOOLREPO      = github.com/twitchtv/retool
RETOOL          = $(GOPATH)/bin/retool
TOOLSPATH       = $(STYLEDIR)/.tools
RETOOLOPTS      = -base-dir='$(STYLEDIR)' -tool-dir='$(TOOLSPATH)'
VALE            = $(TOOLSPATH)/bin/vale
VALEOPTS        = --config '$(STYLEDIR)/_vale.ini'

# Default target
.PHONY: help
help:
	@printf 'This Makefile is not supposed to be run manually.\n'
	@exit 1;

$(VALE):
	'$(GO)' get $(RETOOLREPO)
	@printf '\033[33mThis might take a few minutes. '
	@printf 'Please be patient!\033[00m\n'
	'$(RETOOL)' $(RETOOLOPTS) sync

.PHONY: test
test: $(DOC8) $(VALE)
	@if test ! -d '$(ROOTDIR)'; then \
	    printf 'ROOTDIR has not been set.\n'; \
	    exit 1; \
	fi
	@# 1. Start at the root of the repository
	@# 2. Ignore dot directories
	@# 3. Find all RST files
	@# 4. Run through Vale
	cd '$(ROOTDIR)' && find . \
	    -not -path '*/\.*' \
	    -name '*\.rst' -type f -print0 | xargs -0 \
	        '$(RETOOL)' $(RETOOLOPTS) do vale $(VALEOPTS)

.PHONY: clean
clean:
	rm -rf '$(GOPATH)'
	rm -rf '$(TOOLSPATH)'
