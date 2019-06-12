ifeq ($(BMV2_REPO),)
$(error Must set envronment variable BMV2_REPO)
endif

ifeq ($(P4BOOSTERS_REPO),)
P4BOOSTERS_REPO=$(realpath ../..)
$(info Guessing P4BOOSTERS_REPO is $(P4BOOSTERS_REPO))
endif

BOOSTER_TARGET=booster_switch
TEMPLATE_TARGET=simple_switch

BOOSTERS?=MEMCACHED FEC COMPRESSION
ifneq ($(filter configure,$(MAKECMDGOALS)),)
BOOSTERS:=$(shell ./enabled_boosters.sh ${BOOSTERS})
endif

BMV2_CONFIGURE=$(BMV2_REPO)/configure.ac
TARGETS_DIR=$(BMV2_REPO)/targets

TEMPLATE_TARGET_DIR=$(TARGETS_DIR)/$(TEMPLATE_TARGET)/
BOOSTER_TARGET_DIR=$(TARGETS_DIR)/$(BOOSTER_TARGET)

ifneq ($(findstring FEC,$(BOOSTERS)),)
BOOSTER_DEPS+=booster_switch/fecBoosters
CONFIG_FLAGS+=FEC_BOOSTER=true
$(info Attempting build of fec boosters)
endif

ifneq ($(findstring MEMCACHED,$(BOOSTERS)),)
BOOSTER_DEPS+=booster_switch/memcachedBooster
CONFIG_FLAGS+=MEMCACHED_BOOSTER=true
$(info Attempting build of memcached boosters)
endif

ifneq ($(findstring COMPRESSION,$(BOOSTERS)),)
BOOSTER_DEPS+=booster_switch/compressionBoosters
CONFIG_FLAGS+=COMPRESSION_BOOSTER=true
$(info Attempting build of memcached boosters)
endif


.PHONY:booster_switch patches clean copy_files configure $(BOOSTER_DEPS)

all: $(BOOSTER_DEPS) patches copy_files booster_switch

copy_files: $(BOOSTER_TARGET_DIR)
	rsync -av $(BOOSTER_TARGET)/* $(BOOSTER_TARGET_DIR)

booster_switch/fecBoosters:
	cd ../fecBoosters && make copy_files

booster_switch/memcachedBooster:
	cd ../memcached && make copy_files

booster_switch/compressionBoosters:
	cd ../vjCompressor && make copy_files

booster_switch: copy_files  $(BOOSTER_DEPS)
	cd $(BOOSTER_TARGET_DIR) && make -j8

$(BOOSTER_TARGET_DIR):
	rsync -av $(TEMPLATE_TARGET_DIR) $(BOOSTER_TARGET_DIR)

configure: patches $(BOOSTER_DEPS) copy_files bmv2_clean_configure
	cd $(BOOSTER_TARGET_DIR) && make -j8

bmv2_clean_configure: patches FORCE
	-rm -fr $(BOOSTER_TARGET_DIR)
	rsync -av $(TEMPLATE_TARGET_DIR) $(BOOSTER_TARGET_DIR)
	rsync -av $(BOOSTER_TARGET)/* $(BOOSTER_TARGET_DIR)
	cd $(BMV2_REPO) && ./autogen.sh && ./configure \
		P4BOOSTERS_REPO=$(P4BOOSTERS_REPO) $(CONFIG_FLAGS) && autoconf && automake && make -j8
	- cd $(BOOSTER_TARGET_DIR) && make clean

patches:
	cd patches && bash patch.sh

clean:
	cd $(BOOSTER_TARGET_DIR) && make clean

FORCE:


