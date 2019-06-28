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
ROOT_RST_DIR   := .
STYLE_DIR      := .style
# `STYLE_DIR_ROOT` is path to `STYLE_DIR` from `ROOT_RST_DIR`
STYLE_DIR_ROOT := $(STYLE_DIR)
STYLE_RULES    := $(STYLE_DIR_ROOT)/utils/rules.mk
STYLE_MAKE     := $(MAKE) -C $(ROOT_RST_DIR) -f $(STYLE_RULES)

# Default target
.PHONY: help
help:
	@ printf 'Documentation Utils\n'
	@ echo
	@ printf 'Run `make <TARGET>`, where <TARGET> is one of:\n'
	@ echo
	@ printf '\033[35m  check       \033[00m Build, test, and lint the'
	@ printf                               ' documentation (run by CI)\n'
	@ echo
	@ printf '\033[35m  clean       \033[00m Clean up (e.g., remove lint'
	@ printf                               ' files)\n'
	@ echo
	@ printf '\033[35m  reset       \033[00m Reset the source\n'

$(STYLE_DIR):
	mkdir -p $@
	cp -R utils $@/utils

.PHONY: lint
lint: $(STYLE_DIR)
	@ $(STYLE_MAKE) $@

.PHONY: check
check: lint

.PHONY: clean
clean: $(STYLE_DIR)
	@ $(STYLE_MAKE) $@

.PHONY: reset
reset: clean
	rm -rf $(STYLE_DIR)
