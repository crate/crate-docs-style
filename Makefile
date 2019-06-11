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

ENVDIR          = $(CURDIR)/.env
PYTHON          = python3.7
PIP             = $(ENVDIR)/bin/pip
DOC8            = $(ENVDIR)/bin/doc8
DOC8OPTS        = --config='$(CURDIR)/doc8/config.ini'
GO              = go
GOPATH          = $(CURDIR)/.go
RETOOLREPO      = github.com/twitchtv/retool
RETOOL          = $(GOPATH)/bin/retool
TOOLSPATH       = $(CURDIR)/.tools
RETOOLOPTS      = -base-dir='$(CURDIR)' -tool-dir='$(TOOLSPATH)'
VALE            = $(TOOLSPATH)/bin/vale
VALEOPTS        = --config='$(CURDIR)/vale/config.ini'

# Default target
.PHONY: help
help:
	@printf 'This Makefile is not supposed to be run manually.\n'
	@exit 1;

$(DOC8):
	@if test ! -d '$(ROOTDIR)'; then \
	    printf 'ROOTDIR has not been set.\n'; \
	    exit 1; \
	fi
	'$(PYTHON)' -m venv '$(ENVDIR)'
	'$(PIP)' install --upgrade pip
	'$(PIP)' install -r '$(CURDIR)/requirements.txt'
	# Delete third-party RST files from the Python venv, because we don't want
	# to test them
	find '$(ENVDIR)' -name '*.rst' -delete

$(VALE):
	'$(GO)' get $(RETOOLREPO)
	@printf '\033[33mThis might take a few minutes. '
	@printf 'Please be patient!\033[00m\n'
	'$(RETOOL)' $(RETOOLOPTS) sync

# We use $(ROOTDIR) to test all RST files, not just those under `docs`
.PHONY: stylecheck
test: $(DOC8) $(VALE)
	'$(DOC8)'  $(DOC8OPTS) '$(ROOTDIR)'
	'$(RETOOL)' $(RETOOLOPTS) do vale $(VALEOPTS) '$(ROOTDIR)'

.PHONY: clean
clean:
	rm -rf '$(ENVDIR)'
	rm -rf '$(GOPATH)'
	rm -rf '$(TOOLSPATH)'
	rm -f .init-stamp
