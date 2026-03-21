#!/usr/bin/make -f

# Adjust according to the number CPU cores to use for parallel build.
# Default: Number of processors in /proc/cpuinfo, if present, or 1.
NR_CPU := $(shell [ -f /proc/cpuinfo ] && grep -c '^processor\s*:' /proc/cpuinfo || echo 1)
BB_NUMBER_THREADS ?= $(NR_CPU)
PARALLEL_MAKE ?= -j $(NR_CPU)

XSUM ?= md5sum
DISTRO_TYPE ?= release
DISTRO ?= openatv
ONLINECHECK_URL ?= "https://github.com/"
ONLINECHECK_TIMEOUT ?= 2

BUILD_DIR = $(CURDIR)/builds/$(DISTRO)/$(DISTRO_TYPE)/$(MACHINE)
TOPDIR = $(BUILD_DIR)
DL_DIR = $(CURDIR)/sources
SSTATE_DIR = $(CURDIR)/builds/$(DISTRO)/sstate-cache
TMPDIR = $(TOPDIR)/tmp
DEPDIR = $(TOPDIR)/.deps
MACHINEBUILD := $(MACHINE)
export MACHINEBUILD

METAQT=meta-qt5.15
#ifeq ($(MACHINEBUILD),gbquad4k)
#METAQT=meta-qt5.15
#endif


BBLAYERS ?= \
	$(CURDIR)/meta-local \
	$(CURDIR)/meta-oe-alliance/meta-oe \
	$(CURDIR)/openembedded-core/meta \
	$(CURDIR)/meta-openembedded/meta-oe \
	$(CURDIR)/meta-openembedded/meta-multimedia \
	$(CURDIR)/meta-openembedded/meta-networking \
	$(CURDIR)/meta-openembedded/meta-filesystems \
	$(CURDIR)/meta-openembedded/meta-python \
	$(CURDIR)/meta-openembedded/meta-webserver \
	$(CURDIR)/meta-python2 \
	$(CURDIR)/$(METAQT) \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-abcom \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-airdigital \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-amiko \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-anadol \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-ax \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-blackbox \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-beyonwiz \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-ceryon \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-dags \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-dinobot \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-dream \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-edision \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-entwopia \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-formuler \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-gfutures \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-gigablue \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-ini \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-maxytec \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-broadmedia \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-odin \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-octagon \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-protek \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-qviart \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-skylake \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-tiviar \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-tripledot \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-uclan \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-ultramini \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-vuplus \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-xp \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-xtrend \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-xcore \

CONFFILES = \
	$(TOPDIR)/env.source \
	$(TOPDIR)/conf/$(DISTRO).conf \
	$(TOPDIR)/conf/bblayers.conf \
	$(TOPDIR)/conf/local.conf \
	$(TOPDIR)/conf/site.conf

CONFDEPS = \
	$(DEPDIR)/.env.source.$(BITBAKE_ENV_HASH) \
	$(DEPDIR)/.$(DISTRO).conf.$($(DISTRO)_CONF_HASH) \
	$(DEPDIR)/.bblayers.conf.$(BBLAYERS_CONF_HASH) \
	$(DEPDIR)/.local.conf.$(LOCAL_CONF_HASH)

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
	@echo "MACHINE=mutant2400 DISTRO=openatv DISTRO_TYPE=release make image"
	@echo "	or"
	@echo "cd $(BUILD_DIR) ; source env.source ; bitbake $(DISTRO)-image"
	@echo
	@echo "To download all sources for image build:"
	@echo "MACHINE=mutant2400 DISTRO=openatv DISTRO_TYPE=release make download"
	@echo " or"
	@echo "cd $(BUILD_DIR) ; source env.source ; bitbake $(DISTRO)-image --runall=fetch"
	@echo
	@echo "To build image without feed:"
	@echo "MACHINE=mutant2400 DISTRO=openatv DISTRO_TYPE=release make enigma2-image"
	@echo " or"
	@echo "cd $(BUILD_DIR) ; source env.source ; bitbake $(DISTRO)-enigma2-image"
	@echo
	@echo "To build feeds:"
	@echo "MACHINE=mutant2400 DISTRO=openatv DISTRO_TYPE=release make feeds"
	@echo " or"
	@echo "cd $(BUILD_DIR) ; source env.source ; bitbake $(DISTRO)-feeds"
	@echo

$(BBLAYERS):
	[ -d $@ ] || $(MAKE) $(MFLAGS) update

METADIR = $(CURDIR)/meta-oe-alliance/meta-brands

# Dynamic setupmbuild: resolve MACHINEBUILD -> MACHINE via conf annotations
_FOUND_CONF := $(shell grep -rl "^\# MACHINEBUILDS:.*\b$(MACHINEBUILD)\b" $(METADIR)/*/conf/machine/*.conf 2>/dev/null | head -1)
ifneq ($(_FOUND_CONF),)
  override MACHINE := $(basename $(notdir $(_FOUND_CONF)))
endif

setupmbuild:
	@if [ ! -f "$(METADIR)/*/conf/machine/$(MACHINE).conf" ] && \
	    ! ls $(METADIR)/*/conf/machine/$(MACHINE).conf >/dev/null 2>&1; then \
		echo "ERROR: No machine config found for MACHINE=$(MACHINE) (MACHINEBUILD=$(MACHINEBUILD))"; \
		exit 1; \
	fi

initialize: init

init: setupmbuild $(BBLAYERS) $(CONFFILES)

image: init
	@. $(TOPDIR)/env.source && cd $(TOPDIR) && bitbake $(DISTRO)-image

enigma2-image: init
	@. $(TOPDIR)/env.source && cd $(TOPDIR) && bitbake $(DISTRO)-enigma2-image

feeds: init
	@. $(TOPDIR)/env.source && cd $(TOPDIR) && bitbake $(DISTRO)-feeds
	@. $(TOPDIR)/env.source && cd $(TOPDIR) && bitbake package-index

devel: init
	@. $(TOPDIR)/env.source && cd $(TOPDIR) && bitbake $(DISTRO)-devel

clean:
	@. $(TOPDIR)/env.source && cd $(TOPDIR) && echo -n -e "Performing a clean \e[95mPlease wait... " && bitbake -qqq -c clean $(DISTRO)-image && echo -n -e "\e[93mClean completed.\e[0m"

download: init
	@echo 'Downloading sources'
	@. $(TOPDIR)/env.source && cd $(TOPDIR) && bitbake $(DISTRO)-image --runall=fetch

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
		cd meta-oe-alliance  && \
		if [ -n "$(GIT_REMOTE)" ]; then \
			$(GIT) submodule sync && \
			$(GIT) submodule update --init; \
		fi; \
		echo "The oe-alliance is now up-to-date." ; \
		cd .. ; \
	fi

.PHONY: all image enigma2-image feed devel init initialize update usage machinebuild list

BITBAKE_ENV_HASH := $(call hash, \
	'BITBAKE_ENV_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	'MACHINEBUILD2 = "${MACHINEBUILD}"' \
	)

$(TOPDIR)/env.source: $(DEPDIR)/.env.source.$(BITBAKE_ENV_HASH)
	@echo 'Generating $@'
	@echo 'export BB_ENV_PASSTHROUGH_ADDITIONS="MACHINE DISTRO MACHINEBUILD BB_SRCREV_POLICY BB_NO_NETWORK"' > $@
	@echo 'export MACHINE=$(MACHINE)' >> $@
	@echo 'export DISTRO=$(DISTRO)' >> $@
	@echo 'export MACHINEBUILD=$(MACHINEBUILD)' >> $@
	@echo 'export PATH=$(CURDIR)/openembedded-core/scripts:$(CURDIR)/bitbake/bin:$${PATH}' >> $@
	@echo 'if [[ $$BB_NO_NETWORK -eq 1 ]]; then' >> $@
	@echo ' export BB_SRCREV_POLICY="cache"' >> $@
	@echo ' echo -e "\e[95mforced offline mode\e[0m"' >> $@
	@echo 'else' >> $@
	@echo ' echo -n -e "check internet connection: \e[93mWaiting ...\e[0m"' >> $@
	@echo ' wget -q --tries=10 --timeout=$(ONLINECHECK_TIMEOUT) --spider $(ONLINECHECK_URL)' >> $@
	@echo ' if [[ $$? -eq 0 ]]; then' >> $@
	@echo '  echo -e "\b\b\b\b\b\b\b\b\b\b\b\e[32mOnline      \e[0m"' >> $@
	@echo ' else' >> $@
	@echo '  echo -e "\b\b\b\b\b\b\b\b\b\b\b\e[31mOffline     \e[0m"' >> $@
	@echo '  export BB_SRCREV_POLICY="cache"' >> $@
	@echo ' fi' >> $@
	@echo 'fi' >> $@

$(DISTRO)_CONF_HASH := $(call hash, \
	'$(DISTRO)_CONF_VERSION = "1"' \
	'CURDIR = "$(CURDIR)"' \
	'BB_NUMBER_THREADS = "$(BB_NUMBER_THREADS)"' \
	'PARALLEL_MAKE = "$(PARALLEL_MAKE)"' \
	'DL_DIR = "$(DL_DIR)"' \
	'SSTATE_DIR = "$(SSTATE_DIR)"' \
	'BB_HASHSERVE_DB_DIR = "$(SSTATE_DIR)"' \
	'TMPDIR = "$(TMPDIR)"' \
	)

$(TOPDIR)/conf/$(DISTRO).conf: $(DEPDIR)/.$(DISTRO).conf.$($(DISTRO)_CONF_HASH)
	@echo 'Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo 'DISTRO_TYPE = "$(DISTRO_TYPE)"' >> $@
	@echo 'TMPDIR = "$(TMPDIR)"' >> $@
	@echo 'BB_GENERATE_MIRROR_TARBALLS = "1"' >> $@
	@echo 'BBINCLUDELOGS = "yes"' >> $@
	@echo 'CONF_VERSION = "2"' >> $@
	@echo 'USER_CLASSES = "buildstats"' >> $@
	@echo '#PRSERV_HOST = "localhost:0"' >> $@


LOCAL_CONF_HASH := $(call hash, \
	'LOCAL_CONF_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	'TOPDIR = "$(TOPDIR)"' \
	)

$(TOPDIR)/conf/local.conf: $(DEPDIR)/.local.conf.$(LOCAL_CONF_HASH)
	@echo 'Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo 'TOPDIR = "$(TOPDIR)"' > $@
	@echo 'require $(TOPDIR)/conf/$(DISTRO).conf' >> $@

$(TOPDIR)/conf/site.conf: $(CURDIR)/site.conf
	@ln -s ../../../../../site.conf $@

$(CURDIR)/site.conf:
	@echo 'SCONF_VERSION = "1"' >> $@
	@echo 'BB_NUMBER_THREADS = "$(BB_NUMBER_THREADS)"' >> $@
	@echo 'PARALLEL_MAKE = "$(PARALLEL_MAKE)"' >> $@
	@echo 'BUILD_OPTIMIZATION = "-O2 -pipe"' >> $@
	@echo 'DL_DIR = "$(DL_DIR)"' >> $@
	@echo 'SSTATE_DIR = "$(SSTATE_DIR)"' >> $@
	@echo 'BB_HASHSERVE_DB_DIR = "$(SSTATE_DIR)"' >> $@
	@echo 'INHERIT += "rm_work"' >> $@
	@echo 'INHERIT:remove = "create-spdx"' >> $@
	@echo '#BB_GIT_SHALLOW_DEPTH = "1"' >> $@
	@echo 'BB_GIT_SHALLOW = "0"' >> $@

BBLAYERS_CONF_HASH := $(call hash, \
	'BBLAYERS_CONF_VERSION = "5"' \
	'CURDIR = "$(CURDIR)"' \
	'BBLAYERS = "$(BBLAYERS)"' \
	)

$(TOPDIR)/conf/bblayers.conf: $(DEPDIR)/.bblayers.conf.$(BBLAYERS_CONF_HASH)
	@echo 'Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo 'LCONF_VERSION = "4"' > $@
	@echo 'BBFILES = ""' >> $@
	@echo 'BBLAYERS = "$(BBLAYERS)"' >> $@

$(CONFDEPS):
	@test -d $(@D) || mkdir -p $(@D)
	@$(RM) $(basename $@).*
	@touch $@



# Extract filter arguments: make list gbq arm -> FILTERS="gbq arm"
ifneq ($(filter list,$(MAKECMDGOALS)),)
  FILTERS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  ifneq ($(FILTERS),)
    $(foreach f,$(FILTERS),$(eval $(f):;@:))
  endif
endif

define LIST_SCRIPT
import os, re, sys, glob

confdir, filters = sys.argv[1], sys.argv[2:]

tunes = {}
for r, _, fs in os.walk(confdir):
	for f in fs:
		if f.endswith(('.conf', '.inc')):
			p = os.path.join(r, f)
			for l in open(p):
				m = re.match(r'^DEFAULTTUNE\s*=\s*"([^"]+)"', l)
				if m:
					tunes[p] = m.group(1)
					break

def get_incs(path):
	try:
		return [re.sub(r'^(include|require)\s+', '', l.strip()) for l in open(path) if re.match(r'^(include|require)\s', l)]
	except:
		return []

def to_arch(t):
	if not t: return 'unknown'
	if t.startswith('aarch64'): return 'aarch64'
	if t.startswith(('cortexa', 'arm')): return 'arm'
	if t.startswith('mips'): return 'mipsel'
	return 'unknown'

def get_arch(conf, br):
	if conf in tunes: return to_arch(tunes[conf])
	for i in get_incs(conf):
		p = os.path.join(br, i)
		if p in tunes: return to_arch(tunes[p])
		for i2 in get_incs(p):
			p2 = os.path.join(br, i2)
			if p2 in tunes: return to_arch(tunes[p2])
	return 'unknown'

def matches(machine, oem, arch, meta):
	for f in filters:
		if f in ('aarch64', 'arm', 'mips', 'mipsel'):
			af = 'mipsel' if f == 'mips' else f
			if arch != af: return False
		elif f.lower() not in f'{machine} {oem} {meta}'.lower():
			return False
	return True

n = 0
print(f"{'#':>4} {'MACHINE':<20} {'OEM':<20} {'META':<18} ARCH")
print(f"{'----':>4} {'--------------------':<20} {'--------------------':<20} {'------------------':<18} --------")

for conf in sorted(glob.glob(os.path.join(confdir, '*/conf/machine/*.conf'))):
	machine = os.path.basename(conf)[:-5]
	meta = 'meta-' + re.search(r'meta-brands/meta-([^/]+)/', conf).group(1)
	br = conf.rsplit('/conf/machine/', 1)[0]
	arch = get_arch(conf, br)
	builds = ''
	for l in open(conf):
		if l.startswith('# MACHINEBUILDS:'):
			builds = l.replace('# MACHINEBUILDS:', '').strip()
			break
	if builds:
		for oem in builds.split():
			if matches(oem, machine, arch, meta):
				n += 1; print(f'{n:4d} {oem:<20} {machine:<20} {meta:<18} {arch}'); sys.stdout.flush()
	elif matches(machine, machine, arch, meta):
		n += 1; print(f'{n:4d} {machine:<20} {machine:<20} {meta:<18} {arch}'); sys.stdout.flush()
endef

export LIST_SCRIPT

list:
	@python3 -c "$$LIST_SCRIPT" "$(METADIR)" $(FILTERS)
