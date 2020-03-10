#
# Litesite Makefile
#
# Version: 1.0
# Author: David Kaumanns

################################################################################
# Configuration

# Binaries
PERL ?= /usr/bin/perl
SHELL ?= /bin/bash
RSYNC ?= /usr/bin/rsync
PANDOC ?= /usr/local/bin/pandoc

# Extension for source files
PANDOC_EXTENSION = md

# HTML templates
TEMPLATE_ARTICLE = src/template.article.html
TEMPLATE_INDEX = src/template.index.html

# Remote directory for sync
DESTINATION = metta@wirtanen.uberspace.de:~/metta/heidenblog.de

# Directories
OUT = out
SRC = src
ASSETS = assets

################################################################################
# Definitions

.SECONDEXPANSION:

vpath %.$(PANDOC_EXTENSION) $(SRC)
vpath %.html $(OUT)

SRC_FILES = $(shell echo $(SRC)/*.$(PANDOC_EXTENSION))
ARTICLES = $(foreach file,$(SRC_FILES),$(patsubst %.$(PANDOC_EXTENSION),%.article,$(notdir $(file))))

reverse = $(if $(1),$(call reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1))

define apply_prerequisites_to_template
cat $(wordlist 2,$(words $^),$^) \
	| $(PERL) -MFile::Slurp -e 'binmode STDIN, ":encoding(UTF-8)"; binmode STDOUT, ":encoding(UTF-8)"; my $$body = do { local $$/; <STDIN> }; my $$template = read_file("$(firstword $^)", { binmode => ":encoding(UTF-8)" }); $$template =~ s/\$$body\$$/$$body/; print($$template)' \
	> $@
endef

.PHONY: default clean site sync

################################################################################
# Recipes

default:
	$(MAKE) site
	$(MAKE) sync

clean:
	rm -rf $(OUT)

site: $(OUT)/index.html
	rsync -r $(ASSETS) $(OUT)/

%.article: $(TEMPLATE_ARTICLE) %.$(PANDOC_EXTENSION)
	cat $(lastword $^) \
		| $(PANDOC) \
			--from markdown \
			--to html \
			--template $(firstword $^) \
			--variable url="$$(basename $(lastword $^) .$(PANDOC_EXTENSION)).html" \
			--email-obfuscation=references \
		> $@

%/index.html: $(TEMPLATE_INDEX) $(call reverse,$(ARTICLES))
	mkdir -p $(OUT)
	$(apply_prerequisites_to_template)
	for file in $(wordlist 2,$(words $^),$^); do \
		$(MAKE) $*/$${file%.*}.html; \
	done;

%.html: $(TEMPLATE_INDEX) $$(notdir $$*).article
	$(apply_prerequisites_to_template)

sync:
	$(RSYNC) \
		--delete \
		--verbose \
		--compress \
		--recursive \
		$(OUT)/* \
		$(DESTINATION)

