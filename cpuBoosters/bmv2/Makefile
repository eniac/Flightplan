.PHONY:booster_switch patches clean

ifeq ($(BMV2_REPO),)
$(error Must set envronment variable BMV2_REPO)
endif

ifeq ($(P4BOOSTERS_REPO),)
P4BOOSTERS_REPO=$(realpath ../..)
$(info Guessing P4BOOSTERS_REPO is $(P4BOOSTERS_REPO))
endif

BOOSTER_TARGET=booster_switch
TEMPLATE_TARGET=simple_switch

BOOSTERS?=MEMCACHED FEC

ifneq ($(findstring MEMCACHED,$(BOOSTERS)),)
BUILD_MEMCACHED=true
else
BUILD_MEMCACHED=false
endif

ifneq ($(findstring FEC,$(BOOSTERS)),)
BUILD_FEC=true
else
BUILD_FEC=false
endif

BMV2_CONFIGURE=$(BMV2_REPO)/configure.ac
TARGETS_DIR=$(BMV2_REPO)/targets

TEMPLATE_TARGET_DIR=$(TARGETS_DIR)/$(TEMPLATE_TARGET)/
BOOSTER_TARGET_DIR=$(TARGETS_DIR)/$(BOOSTER_TARGET)

ifeq ($(BUILD_FEC),true)
BOOSTER_DEPS+=booster_switch/fecBoosters
CONFIG_FLAGS+=FEC_BOOSTER=true
$(info Attempting build of fec boosters)
endif

ifeq ($(BUILD_MEMCACHED),true)
BOOSTER_DEPS+=booster_switch/memcachedBooster
CONFIG_FLAGS+=MEMCACHED_BOOSTER=true
$(info Attempting build of memcached boosters)
endif

all: patches copy_files $(BMV2_CONFIGURE) booster_switch

copy_files: $(BOOSTER_TARGET_DIR)
	rsync -av $(BOOSTER_TARGET)/* $(BOOSTER_TARGET_DIR)

booster_switch/fecBoosters:
	cd ../fecBoosters && make copy_files

booster_switch/memcachedBooster:
	cd ../memcached && make copy_files

booster_switch: copy_files  $(BOOSTER_DEPS)
	cd $(BOOSTER_TARGET_DIR) && make

$(BOOSTER_TARGET_DIR):
	rsync -av $(TEMPLATE_TARGET_DIR) $(BOOSTER_TARGET_DIR)

$(BMV2_CONFIGURE): Makefile
	cd $(BMV2_REPO) && ./configure P4BOOSTERS_REPO=$(P4BOOSTERS_REPO) \
		$(CONFIG_FLAGS) && autoconf
	# Hacky way to recognize that configuration is newer than makefile
	# Might be causing configuration to be run twice on first go-through...
	touch $(BMV2_CONFIGURE)

patches:
	cd patches && bash patch.sh

clean:
	cd $(BOOSTER_TARGET_DIR) && make clean
