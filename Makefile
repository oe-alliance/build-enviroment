#!/usr/bin/make -f

# Adjust according to the number CPU cores to use for parallel build.
# Default: Number of processors in /proc/cpuinfo, if present, or 1.
NR_CPU := $(shell [ -f /proc/cpuinfo ] && grep -c '^processor\s*:' /proc/cpuinfo || echo 1)
BB_NUMBER_THREADS ?= $(NR_CPU)
PARALLEL_MAKE ?= -j $(NR_CPU)

XSUM ?= md5sum
DISTRO_TYPE ?= release
DISTRO ?= openatv

BUILD_DIR = $(CURDIR)/builds/$(DISTRO)/$(DISTRO_TYPE)/$(MACHINE)
TOPDIR = $(BUILD_DIR)
DL_DIR = $(CURDIR)/sources
SSTATE_DIR = $(CURDIR)/builds/$(DISTRO)/sstate-cache
TMPDIR = $(TOPDIR)/tmp
DEPDIR = $(TOPDIR)/.deps
MACHINEBUILD = $(MACHINE)
export MACHINEBUILD

BBLAYERS ?= \
	$(CURDIR)/openembedded-core/meta \
	$(CURDIR)/meta-openembedded/meta-oe \
	$(CURDIR)/meta-openembedded/meta-multimedia \
	$(CURDIR)/meta-openembedded/meta-networking \
	$(CURDIR)/meta-openembedded/meta-filesystems \
	$(CURDIR)/meta-openembedded/meta-python \
	$(CURDIR)/meta-oe-alliance/meta-oe \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-airdigital \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-azbox \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-ax \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-blackbox \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-ceryon \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-cube \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-dags \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-dream \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-ebox \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-entwopia \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-formuler \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-fulan \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-gigablue \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-ini \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-ixuss \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-broadmedia \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-odin \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-skylake \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-tripledot \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-ultramini \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-vuplus \
    $(CURDIR)/meta-oe-alliance/meta-brands/meta-wetek \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-xp \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-xtrend \
	$(CURDIR)/meta-oe-alliance/meta-brands/meta-xcore \
	$(CURDIR)/meta-local \


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

$(BBLAYERS):
	[ -d $@ ] || $(MAKE) $(MFLAGS) update

setupmbuild:
ifeq ($(MACHINEBUILD),tm2t)
MACHINE=dags7335
MACHINEBUILD=tm2t
else ifeq ($(MACHINEBUILD),tmnano)
MACHINE=dags7335
MACHINEBUILD=tmnano
else ifeq ($(MACHINEBUILD),tmnano2t)
MACHINE=dags7335
MACHINEBUILD=tmnano2t
else ifeq ($(MACHINEBUILD),tmsingle)
MACHINE=dags7335
MACHINEBUILD=tmsingle
else ifeq ($(MACHINEBUILD),tmtwin)
MACHINE=dags7335
MACHINEBUILD=tmtwin
else ifeq ($(MACHINEBUILD),iqonios100hd)
MACHINE=dags7335
MACHINEBUILD=iqonios100hd
else ifeq ($(MACHINEBUILD),iqonios300hd)
MACHINE=dags7335
MACHINEBUILD=iqonios300hd
else ifeq ($(MACHINEBUILD),iqonios300hdv2)
MACHINE=dags7335
MACHINEBUILD=iqonios300hdv2
else ifeq ($(MACHINEBUILD),optimussos1)
MACHINE=dags7335
MACHINEBUILD=optimussos1
else ifeq ($(MACHINEBUILD),mediabox)
MACHINE=dags7335
MACHINEBUILD=mediabox
else ifeq ($(MACHINEBUILD),iqonios200hd)
MACHINE=dags7335
MACHINEBUILD=iqonios200hd
else ifeq ($(MACHINEBUILD),roxxs200hd)
MACHINE=dags7335
MACHINEBUILD=roxxs200hd
else ifeq ($(MACHINEBUILD),mediaart200hd)
MACHINE=dags7335
MACHINEBUILD=mediaart200hd
else ifeq ($(MACHINEBUILD),optimussos2)
MACHINE=dags7335
MACHINEBUILD=optimussos2
else ifeq ($(MACHINEBUILD),tmnano2super)
MACHINE=dags7356
MACHINEBUILD=tmnano2super
else ifeq ($(MACHINEBUILD),tmnano3t)
MACHINE=dags7356
MACHINEBUILD=tmnano3t
else ifeq ($(MACHINEBUILD),tmnanose)
MACHINE=dags7362
MACHINEBUILD=tmnanose
else ifeq ($(MACHINEBUILD),tmnanosem2)
MACHINE=dags7362
MACHINEBUILD=tmnanosem2
else ifeq ($(MACHINEBUILD),tmnanosecombo)
MACHINE=dags7362
MACHINEBUILD=tmnanosecombo
else ifeq ($(MACHINEBUILD),force1)
MACHINE=dags7356
MACHINEBUILD=force1
else ifeq ($(MACHINEBUILD),force1plus)
MACHINE=dags7356
MACHINEBUILD=force1plus
else ifeq ($(MACHINEBUILD),megaforce1plus)
MACHINE=dags7356
MACHINEBUILD=megaforce1plus
else ifeq ($(MACHINEBUILD),worldvisionf1)
MACHINE=dags7356
MACHINEBUILD=worldvisionf1
else ifeq ($(MACHINEBUILD),worldvisionf1plus)
MACHINE=dags7356
MACHINEBUILD=worldvisionf1plus
else ifeq ($(MACHINEBUILD),optimussos1plus)
MACHINE=dags7356
MACHINEBUILD=optimussos1plus
else ifeq ($(MACHINEBUILD),optimussos2plus)
MACHINE=dags7356
MACHINEBUILD=optimussos2plus
else ifeq ($(MACHINEBUILD),optimussos3plus)
MACHINE=dags7356
MACHINEBUILD=optimussos3plus
else ifeq ($(MACHINEBUILD),force2plus)
MACHINE=dags7362
MACHINEBUILD=force2plus
else ifeq ($(MACHINEBUILD),force2)
MACHINE=dags7362
MACHINEBUILD=force2
else ifeq ($(MACHINEBUILD),megaforce2)
MACHINE=dags7362
MACHINEBUILD=megaforce2
else ifeq ($(MACHINEBUILD),optimussos)
MACHINE=dags7362
MACHINEBUILD=optimussos
else ifeq ($(MACHINEBUILD),fusionhd)
MACHINE=dags7362
MACHINEBUILD=fusionhd

else ifeq ($(MACHINEBUILD),classm)
MACHINE=odinm7
MACHINEBUILD=classm
else ifeq ($(MACHINEBUILD),axodin)
MACHINE=odinm7
MACHINEBUILD=axodin
else ifeq ($(MACHINEBUILD),axodinc)
MACHINE=odinm7
MACHINEBUILD=axodinc
else ifeq ($(MACHINEBUILD),starsatlx)
MACHINE=odinm7
MACHINEBUILD=starsatlx
else ifeq ($(MACHINEBUILD),genius)
MACHINE=odinm7
MACHINEBUILD=genius
else ifeq ($(MACHINEBUILD),evo)
MACHINE=odinm7
MACHINEBUILD=evo
else ifeq ($(MACHINEBUILD),galaxym6)
MACHINE=odinm7
MACHINEBUILD=galaxym6
else ifeq ($(MACHINEBUILD),maram9)
MACHINE=odinm9
MACHINEBUILD=maram9

else ifeq ($(MACHINEBUILD),geniuse3hd)
MACHINE=e3hd
MACHINEBUILD=geniuse3hd
else ifeq ($(MACHINEBUILD),evoe3hd)
MACHINE=e3hd
MACHINEBUILD=evoe3hd
else ifeq ($(MACHINEBUILD),axase3)
MACHINE=e3hd
MACHINEBUILD=axase3
else ifeq ($(MACHINEBUILD),axase3c)
MACHINE=e3hd
MACHINEBUILD=axase3c

else ifeq ($(MACHINEBUILD),ventonhdx)
MACHINE=inihdx
MACHINEBUILD=ventonhdx
else ifeq ($(MACHINEBUILD),sezam5000hd)
MACHINE=inihdx
MACHINEBUILD=sezam5000hd
else ifeq ($(MACHINEBUILD),mbtwin)
MACHINE=inihdx
MACHINEBUILD=mbtwin
else ifeq ($(MACHINEBUILD),beyonwizt3)
MACHINE=inihdx
MACHINEBUILD=beyonwizt3
else ifeq ($(MACHINEBUILD),sezam1000hd)
MACHINE=inihde
MACHINEBUILD=sezam1000hd
else ifeq ($(MACHINEBUILD),xpeedlx)
MACHINE=inihde
MACHINEBUILD=xpeedlx
else ifeq ($(MACHINEBUILD),mbmini)
MACHINE=inihde
MACHINEBUILD=mbmini
else ifeq ($(MACHINEBUILD),atemio5x00)
MACHINE=inihde
MACHINEBUILD=atemio5x00
else ifeq ($(MACHINEBUILD),bwidowx)
MACHINE=inihde
MACHINEBUILD=bwidowx
else ifeq ($(MACHINEBUILD),atemio6000)
MACHINE=inihde2
MACHINEBUILD=atemio6000
else ifeq ($(MACHINEBUILD),atemio6100)
MACHINE=inihde2
MACHINEBUILD=atemio6100
else ifeq ($(MACHINEBUILD),atemio6200)
MACHINE=inihde2
MACHINEBUILD=atemio6200
else ifeq ($(MACHINEBUILD),mbminiplus)
MACHINE=inihde2
MACHINEBUILD=mbminiplus
else ifeq ($(MACHINEBUILD),mbhybrid)
MACHINE=inihde2
MACHINEBUILD=mbhybrid
else ifeq ($(MACHINEBUILD),bwidowx2)
MACHINE=inihde2
MACHINEBUILD=bwidowx2
else ifeq ($(MACHINEBUILD),beyonwizt2)
MACHINE=inihde2
MACHINEBUILD=beyonwizt2
else ifeq ($(MACHINEBUILD),opticumtt)
MACHINE=inihde2
MACHINEBUILD=opticumtt
else ifeq ($(MACHINEBUILD),sezammarvel)
MACHINE=inihdp
MACHINEBUILD=sezammarvel
else ifeq ($(MACHINEBUILD),xpeedlx3)
MACHINE=inihdp
MACHINEBUILD=xpeedlx3
else ifeq ($(MACHINEBUILD),atemionemesis)
MACHINE=inihdp
MACHINEBUILD=atemionemesis
else ifeq ($(MACHINEBUILD),mbultra)
MACHINE=inihdp
MACHINEBUILD=mbultra
else ifeq ($(MACHINEBUILD),beyonwizt4)
MACHINE=inihdp
MACHINEBUILD=beyonwizt4

else ifeq ($(MACHINEBUILD),mixosf5)
MACHINE=ebox5000
MACHINEBUILD=mixosf5
else ifeq ($(MACHINEBUILD),gi9196m)
MACHINE=ebox5000
MACHINEBUILD=gi9196m
else ifeq ($(MACHINEBUILD),mixosf5mini)
MACHINE=ebox5100
MACHINEBUILD=mixosf5mini
else ifeq ($(MACHINEBUILD),gi9196lite)
MACHINE=ebox5100
MACHINEBUILD=gi9196lite
else ifeq ($(MACHINEBUILD),mixosf7)
MACHINE=ebox7358
MACHINEBUILD=mixosf7
else ifeq ($(MACHINEBUILD),mixoslumi)
MACHINE=eboxlumi
MACHINEBUILD=mixoslumi

else ifeq ($(MACHINEBUILD),dcube)
MACHINE=cube
MACHINEBUILD=dcube
else ifeq ($(MACHINEBUILD),mkcube)
MACHINE=cube
MACHINEBUILD=mkcube
else ifeq ($(MACHINEBUILD),ultima)
MACHINE=cube
MACHINEBUILD=ultima

else ifeq ($(MACHINEBUILD),xp1000mk)
MACHINE=xp1000
MACHINEBUILD=xp1000mk
else ifeq ($(MACHINEBUILD),xp1000max)
MACHINE=xp1000
MACHINEBUILD=xp1000max
else ifeq ($(MACHINEBUILD),sf8)
MACHINE=xp1000
MACHINEBUILD=sf8
else ifeq ($(MACHINEBUILD),xp1000plus)
MACHINE=xp1000
MACHINEBUILD=xp1000plus

else ifeq ($(MACHINEBUILD),sogno8800hd)
MACHINE=blackbox7405
MACHINEBUILD=sogno8800hd
else ifeq ($(MACHINEBUILD),uniboxhde)
MACHINE=blackbox7405
MACHINEBUILD=uniboxhde

else ifeq ($(MACHINEBUILD),enfinity)
MACHINE=ew7358
MACHINEBUILD=enfinity
else ifeq ($(MACHINEBUILD),marvel1)
MACHINE=ew7358
MACHINEBUILD=marvel1
else ifeq ($(MACHINEBUILD),x2plus)
MACHINE=ew7356
MACHINEBUILD=x2plus
else ifeq ($(MACHINEBUILD),bre2ze)
MACHINE=ew7362
MACHINEBUILD=bre2ze

else ifeq ($(MACHINEBUILD),mutant2400)
MACHINE=hd2400
MACHINEBUILD=mutant2400
else ifeq ($(MACHINEBUILD),quadbox2400)
MACHINE=hd2400
MACHINEBUILD=quadbox2400
else ifeq ($(MACHINEBUILD),mutant1100)
MACHINE=hd1100
MACHINEBUILD=mutant1100
else ifeq ($(MACHINEBUILD),vizyonvita)
MACHINE=hd1100
MACHINEBUILD=vizyonvita
else ifeq ($(MACHINEBUILD),mutant1200)
MACHINE=hd1200
MACHINEBUILD=mutant1200
else ifeq ($(MACHINEBUILD),mutant500c)
MACHINE=hd500c
MACHINEBUILD=mutant500c

else ifeq ($(MACHINEBUILD),amiko8900)
MACHINE=spark
MACHINEBUILD=amiko8900
else ifeq ($(MACHINEBUILD),amikomini)
MACHINE=spark
MACHINEBUILD=amikomini
else ifeq ($(MACHINEBUILD),sognorevolution)
MACHINE=spark
MACHINEBUILD=sognorevolution
else ifeq ($(MACHINEBUILD),arguspingulux)
MACHINE=spark
MACHINEBUILD=arguspingulux
else ifeq ($(MACHINEBUILD),arguspinguluxmini)
MACHINE=spark
MACHINEBUILD=arguspinguluxmini
else ifeq ($(MACHINEBUILD),arguspinguluxplus)
MACHINE=spark
MACHINEBUILD=arguspinguluxplus
else ifeq ($(MACHINEBUILD),sparkreloaded)
MACHINE=spark
MACHINEBUILD=sparkreloaded
else ifeq ($(MACHINEBUILD),fulanspark1)
MACHINE=spark
MACHINEBUILD=fulanspark1
else ifeq ($(MACHINEBUILD),sabsolo)
MACHINE=spark
MACHINEBUILD=sabsolo
else ifeq ($(MACHINEBUILD),sparklx)
MACHINE=spark
MACHINEBUILD=sparklx
else ifeq ($(MACHINEBUILD),gis8120)
MACHINE=spark
MACHINEBUILD=gis8120
else ifeq ($(MACHINEBUILD),dynaspark)
MACHINE=spark
MACHINEBUILD=dynaspark
else ifeq ($(MACHINEBUILD),dynasparkplus)
MACHINE=spark
MACHINEBUILD=dynasparkplus

else ifeq ($(MACHINEBUILD),amikoalien)
MACHINE=spark7162
MACHINEBUILD=amikoalien
else ifeq ($(MACHINEBUILD),sognotriple)
MACHINE=spark7162
MACHINEBUILD=sognotriple
else ifeq ($(MACHINEBUILD),sparktriplex)
MACHINE=spark7162
MACHINEBUILD=sparktriplex
else ifeq ($(MACHINEBUILD),sabtriple)
MACHINE=spark7162
MACHINEBUILD=sabtriple
else ifeq ($(MACHINEBUILD),giavatar)
MACHINE=spark7162
MACHINEBUILD=giavatar
else ifeq ($(MACHINEBUILD),sparkone)
MACHINE=spark7162
MACHINEBUILD=sparkone
else ifeq ($(MACHINEBUILD),dynaspark7162)
MACHINE=spark7162
MACHINEBUILD=dynaspark7162

else ifeq ($(MACHINEBUILD),enibox)
MACHINE=vg5000
MACHINEBUILD=enibox
else ifeq ($(MACHINEBUILD),mago)
MACHINE=vg5000
MACHINEBUILD=mago
else ifeq ($(MACHINEBUILD),x1plus)
MACHINE=vg5000
MACHINEBUILD=x1plus
else ifeq ($(MACHINEBUILD),sf108)
MACHINE=vg5000
MACHINEBUILD=sf108
else ifeq ($(MACHINEBUILD),tyrant)
MACHINE=vg1000
MACHINEBUILD=tyrant
else ifeq ($(MACHINEBUILD),xcombo)
MACHINE=vg2000
MACHINEBUILD=xcombo

else ifeq ($(MACHINEBUILD),zgemmash1)
MACHINE=sh1
MACHINEBUILD=zgemmash1
else ifeq ($(MACHINEBUILD),zgemmash2)
MACHINE=sh1
MACHINEBUILD=zgemmash2
else ifeq ($(MACHINEBUILD),zgemmas2s)
MACHINE=sh1
MACHINEBUILD=zgemmas2s
else ifeq ($(MACHINEBUILD),zgemmass)
MACHINE=sh1
MACHINEBUILD=zgemmass

else ifeq ($(MACHINEBUILD),mbmicro)
MACHINE=7000s
MACHINEBUILD=mbmicro
else ifeq ($(MACHINEBUILD),e4hd)
MACHINE=7000s
MACHINEBUILD=e4hd
else ifeq ($(MACHINEBUILD),twinboxlcd)
MACHINE=7100s
MACHINEBUILD=twinboxlcd
else ifeq ($(MACHINEBUILD),odin2hybrid)
MACHINE=7300s
MACHINEBUILD=odin2hybrid

else ifeq ($(MACHINEBUILD),mbtwinplus)
MACHINE=g300
MACHINEBUILD=mbtwinplus
else ifeq ($(MACHINEBUILD),sf3038)
MACHINE=g300
MACHINEBUILD=sf3038

else ifeq ($(MACHINEBUILD),spycat)
MACHINE=xc7362
MACHINEBUILD=spycat
else ifeq ($(MACHINEBUILD),spycatmini)
MACHINE=xc7362
MACHINEBUILD=spycatmini
else ifeq ($(MACHINEBUILD),osmini)
MACHINE=xc7362
MACHINEBUILD=osmini
else ifeq ($(MACHINEBUILD),bcm7358)
MACHINE=xc7358
MACHINEBUILD=bcm7358
else ifeq ($(MACHINEBUILD),vp7358ci)
MACHINE=xc7358ci
MACHINEBUILD=vp7358ci

else ifeq ($(MACHINEBUILD),gb800se)
MACHINE=gb7325
MACHINEBUILD=gb800se
else ifeq ($(MACHINEBUILD),gb800ue)
MACHINE=gb7325
MACHINEBUILD=gb800ue
else ifeq ($(MACHINEBUILD),gb800seplus)
MACHINE=gb7358
MACHINEBUILD=gb800seplus
else ifeq ($(MACHINEBUILD),gb800ueplus)
MACHINE=gb7358
MACHINEBUILD=gb800ueplus
else ifeq ($(MACHINEBUILD),gbipbox)
MACHINE=gb7358
MACHINEBUILD=gbipbox
else ifeq ($(MACHINEBUILD),gbultrase)
MACHINE=gb7362
MACHINEBUILD=gbultrase
else ifeq ($(MACHINEBUILD),gbultraue)
MACHINE=gb7362
MACHINEBUILD=gbultraue
else ifeq ($(MACHINEBUILD),gbx1)
MACHINE=gb7362
MACHINEBUILD=gbx1
else ifeq ($(MACHINEBUILD),gbx3)
MACHINE=gb7362
MACHINEBUILD=gbx3

else ifeq ($(MACHINEBUILD),xpeedlxcs2)
MACHINE=ultramini
MACHINEBUILD=xpeedlxcs2
else ifeq ($(MACHINEBUILD),xpeedlxcc)
MACHINE=ultramini
MACHINEBUILD=xpeedlxcc

endif

initialize: init

init: setupmbuild $(BBLAYERS) $(CONFFILES)

image: init
	@. $(TOPDIR)/env.source && cd $(TOPDIR) && bitbake $(DISTRO)-image

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

.PHONY: all image init initialize update usage machinebuild

BITBAKE_ENV_HASH := $(call hash, \
	'BITBAKE_ENV_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	'MACHINEBUILD2 = "${MACHINEBUILD}"' \
	)

$(TOPDIR)/env.source: $(DEPDIR)/.env.source.$(BITBAKE_ENV_HASH)
	@echo 'Generating $@'
	@echo 'export BB_ENV_EXTRAWHITE="MACHINE DISTRO MACHINEBUILD"' > $@
	@echo 'export MACHINE' >> $@
	@echo 'export DISTRO' >> $@
	@echo 'export MACHINEBUILD' >> $@
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
	@echo 'DISTRO_TYPE = "$(DISTRO_TYPE)"' >> $@
	@echo 'SSTATE_DIR = "$(SSTATE_DIR)"' >> $@
	@echo 'TMPDIR = "$(TMPDIR)"' >> $@
	@echo 'BB_GENERATE_MIRROR_TARBALLS = "1"' >> $@
	@echo 'BBINCLUDELOGS = "yes"' >> $@
	@echo 'CONF_VERSION = "1"' >> $@
	@echo 'EXTRA_IMAGE_FEATURES = "debug-tweaks"' >> $@
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
	@echo 'BUILD_OPTIMIZATION = "-march=native -O2 -pipe"' >> $@
	@echo 'DL_DIR = "$(DL_DIR)"' >> $@
	@echo 'INHERIT += "rm_work"' >> $@

BBLAYERS_CONF_HASH := $(call hash, \
	'BBLAYERS_CONF_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	'BBLAYERS = "$(BBLAYERS)"' \
	)

$(TOPDIR)/conf/bblayers.conf: $(DEPDIR)/.bblayers.conf.$(BBLAYERS_CONF_HASH)
	@echo 'Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo 'LCONF_VERSION = "4"' >> $@
	@echo 'BBFILES = ""' >> $@
	@echo 'BBLAYERS = "$(BBLAYERS)"' >> $@

$(CONFDEPS):
	@test -d $(@D) || mkdir -p $(@D)
	@$(RM) $(basename $@).*
	@touch $@
