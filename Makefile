#!/usr/bin/make -f

# MACHINE examples: dm500hd dm800se dm7020hd dm8000 dm800 e3hd ebox5000 et4x00 et5x00 et6x00 et9x00 gb800se gb800solo gb800ue gbquad iqonios100hd iqonios300hd ixussone ixusszero odinm9 odimm7 tm2t tmsingle tmtwin tmsingle ventonhde ventonhdx vuduo vusolo vuultimo vuuno vusolo2 vuduo2 xp1000 
MACHINE ?= vuultimo
# DISTRO examples: openvix openmips openatv openpl opensif
DISTRO ?= openvix

# Adjust according to the number CPU cores to use for parallel build.
# Default: Number of processors in /proc/cpuinfo, if present, or 1.
NR_CPU := $(shell [ -f /proc/cpuinfo ] && grep -c '^processor\s*:' /proc/cpuinfo || echo 1)
BB_NUMBER_THREADS ?= $(NR_CPU)
PARALLEL_MAKE ?= -j $(NR_CPU)

XSUM ?= md5sum

BUILD_DIR = $(CURDIR)/builds/$(DISTRO)/$(MACHINE)
TOPDIR = $(BUILD_DIR)
DL_DIR = $(CURDIR)/sources
SSTATE_DIR = $(CURDIR)/builds/$(DISTRO)/sstate-cache
TMPDIR = $(TOPDIR)/tmp
DEPDIR = $(TOPDIR)/.deps

BBLAYERS ?= \
	$(CURDIR)/meta-openembedded/meta-oe \
	$(CURDIR)/openembedded-core/meta \
	$(CURDIR)/meta-openpli \
	$(CURDIR)/meta-oe-alliance \

CONFFILES = \
	$(TOPDIR)/env.source \
	$(TOPDIR)/conf/$(DISTRO).conf \
	$(TOPDIR)/conf/bblayers.conf \
	$(TOPDIR)/conf/local.conf \
	$(TOPDIR)/conf/site.conf

CONFDEPS = \
	$(DEPDIR)/.env.source.$(BITBAKE_ENV_HASH) \
	$(DEPDIR)/.$(DISTRO).conf.$($(DISTRO)_CONF_HASH) \
	$(DEPDIR)/.bblayers.conf.$(MACHINE).$(BBLAYERS_CONF_HASH) \
	$(DEPDIR)/.local.conf.$(MACHINE).$(LOCAL_CONF_HASH)

GIT ?= git
GIT_REMOTE := $(shell $(GIT) remote)
GIT_USER_NAME := $(shell $(GIT) config user.name)
GIT_USER_EMAIL := $(shell $(GIT) config user.email)

hash = $(shell echo $(1) | $(XSUM) | awk '{print $$1}')

.DEFAULT_GOAL := all
all: init
	@echo
	@echo "Openembedded for the oe-alliance environment has been initialized"
	@echo "properly. Now you can start building your image, by doing either:"
	@echo
	@echo "MACHINE=vuuno DISTRO=openvix make image"
	@echo "	or"
	@echo "cd $(BUILD_DIR) ; source env.source ; bitbake $(DISTRO)-image"
	@echo

$(BBLAYERS):
	[ -d $@ ] || $(MAKE) $(MFLAGS) update

initialize: init

init: $(BBLAYERS) $(CONFFILES)

layercheck:
	@if [ -e "$(TOPDIR)/conf/local.conf" -a "$(grep require $(TOPDIR)/conf/local.conf)" != "require $(TOPDIR)/conf/$(DISTRO).conf" ]; then rm $(TOPDIR)/conf/local.conf; fi

image: init
	@if [ -d "meta-openpli/conf/machine" ]; then mv meta-openpli/conf/machine meta-openpli/conf/machine_pli; fi
	@if [ -e "meta-openpli/recipes-openpli/enigma2-plugins/enigma2-plugin-extensions-openwebif.bbappend" ]; then mv meta-openpli/recipes-openpli/enigma2-plugins/enigma2-plugin-extensions-openwebif.bbappend meta-openpli/recipes-openpli/enigma2-plugins/enigma2-plugin-extensions-openwebif.bbappend_pli; fi
	@. $(TOPDIR)/env.source && cd $(TOPDIR) && bitbake $(DISTRO)-image
	@if [ -d "meta-openpli/conf/machine_pli" ]; then mv meta-openpli/conf/machine_pli meta-openpli/conf/machine; fi
	@if [ -e "meta-openpli/recipes-openpli/enigma2-plugins/enigma2-plugin-extensions-openwebif.bbappend_pli" ]; then mv meta-openpli/recipes-openpli/enigma2-plugins/enigma2-plugin-extensions-openwebif.bbappend_pli meta-openpli/recipes-openpli/enigma2-plugins/enigma2-plugin-extensions-openwebif.bbappend; fi

update:
	@echo 'Updating Git repositories...'
	@HASH=`$(XSUM) $(MAKEFILE_LIST)`; \
	if [ -n "$(GIT_REMOTE)" ]; then \
		$(GIT) pull --ff-only || $(GIT) pull --rebase; \
	fi; \
	if [ "$$HASH" != "`$(XSUM) $(MAKEFILE_LIST)`" ]; then \
		echo 'Makefile changed. Restarting...'; \
		$(MAKE) $(MFLAGS) --no-print-directory $(MAKECMDGOALS); \
	else \
		$(GIT) submodule sync && \
		$(GIT) submodule update --init && \
		echo "The oe-alliance is now up-to-date."; \
	fi

.PHONY: all image init initialize update usage

BITBAKE_ENV_HASH := $(call hash, \
	'BITBAKE_ENV_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	)

$(TOPDIR)/env.source: $(DEPDIR)/.env.source.$(BITBAKE_ENV_HASH)
	@echo 'Generating $@'
	@echo 'export PATH=$(CURDIR)/openembedded-core/scripts:$(CURDIR)/bitbake/bin:$${PATH}' >> $@

$(DISTRO)_CONF_HASH := $(call hash, \
	'$(DISTRO)_CONF_VERSION = "1"' \
	'CURDIR = "$(CURDIR)"' \
	'BB_NUMBER_THREADS = "$(BB_NUMBER_THREADS)"' \
	'PARALLEL_MAKE = "$(PARALLEL_MAKE)"' \
	'DL_DIR = "$(DL_DIR)"' \
	'SSTATE_DIR = "$(SSTATE_DIR)"' \
	'TMPDIR = "$(TMPDIR)"' \
	)

$(TOPDIR)/conf/$(DISTRO).conf: $(DEPDIR)/.$(DISTRO).conf.$($(DISTRO)_CONF_HASH)
	@echo 'Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo 'SSTATE_DIR = "$(SSTATE_DIR)"' > $@
	@echo 'TMPDIR = "$(TMPDIR)"' >> $@
	@echo 'BB_GENERATE_MIRROR_TARBALLS = "0"' >> $@
	@echo 'BBINCLUDELOGS = "yes"' >> $@
	@echo 'CONF_VERSION = "1"' >> $@
	@echo 'DISTRO = "$(DISTRO)"' >> $@
	@echo 'MACHINEBUILD = "$(MACHINE)"' >> $@
	@echo 'EXTRA_IMAGE_FEATURES = "debug-tweaks"' >> $@
	@echo 'USER_CLASSES = "buildstats"' >> $@
	@if [ -f "$(CURDIR)/branding.conf" ]; then \
		echo "### BRANDING" >> $@; \
		cat $(CURDIR)/branding.conf >> $@; \
	fi

LOCAL_CONF_HASH := $(call hash, \
	'LOCAL_CONF_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	'TOPDIR = "$(TOPDIR)"' \
	'MACHINE = "$(MACHINE)"' \
	)

$(TOPDIR)/conf/local.conf: $(DEPDIR)/.local.conf.$(MACHINE).$(LOCAL_CONF_HASH)
	@echo 'Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo 'TOPDIR = "$(TOPDIR)"' > $@
	@if [ "$(MACHINE)" = "dm7020hdv2" ]; then \
		echo 'MACHINE = "dm7020hd"' >> $@; \
	else \
		echo 'MACHINE = "$(MACHINE)"' >> $@; \
	fi
	@echo 'require $(TOPDIR)/conf/$(DISTRO).conf' >> $@

$(TOPDIR)/conf/site.conf: $(CURDIR)/site.conf
	@ln -s ../../../../site.conf $@

$(CURDIR)/site.conf:
	@echo 'SCONF_VERSION = "1"' > $@
	@echo 'BB_NUMBER_THREADS = "$(BB_NUMBER_THREADS)"' >> $@
	@echo 'PARALLEL_MAKE = "$(PARALLEL_MAKE)"' >> $@
	@echo 'BUILD_OPTIMIZATION = "-march=native -O2 -pipe"' >> $@
	@echo 'DL_DIR = "$(DL_DIR)"' >> $@

BBLAYERS_CONF_HASH := $(call hash, \
	'BBLAYERS_CONF_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	'BBLAYERS = "$(BBLAYERS)"' \
	)

$(TOPDIR)/conf/bblayers.conf: $(DEPDIR)/.bblayers.conf.$(MACHINE).$(BBLAYERS_CONF_HASH)
	@echo 'Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo 'LCONF_VERSION = "4"' >> $@
	@echo 'BBFILES = ""' >> $@
	@echo 'BBLAYERS = "$(BBLAYERS)"' >> $@

$(CONFDEPS):
	@test -d $(@D) || mkdir -p $(@D)
	@$(RM) $(basename $@).*
	@touch $@
