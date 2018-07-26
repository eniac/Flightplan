.PHONY:booster_switch patches

ifeq ($(BMV2_REPO),)
$(error Must set envronment variable BMV2_REPO)
endif

ifeq ($(P4BOOSTERS_REPO),)
P4BOOSTERS_REPO=$(realpath ../..)
$(warning Guessing P4BOOSTERS_REPO is $(P4BOOSTERS_REPO))
endif

BOOSTER_TARGET=booster_switch
TEMPLATE_TARGET=simple_switch

TARGETS_DIR=$(BMV2_REPO)/targets
TEMPLATE_TARGET_DIR=$(TARGETS_DIR)/$(TEMPLATE_TARGET)/
BOOSTER_TARGET_DIR=$(TARGETS_DIR)/$(BOOSTER_TARGET)

ifeq ($(wildcard booster_switch/fecBoosters),)
$(error must run 'make bmv2' in $(realpath ../fecBoosters) first)
endif

booster_switch: $(BOOSTER_TARGET_DIR) patches booster_switch/fecBoosters/
	rsync -av $(BOOSTER_TARGET)/* $(BOOSTER_TARGET_DIR)
	cd $(BOOSTER_TARGET_DIR) && make P4BOOSTERS_REPO=$(P4BOOSTERS_REPO)

$(BOOSTER_TARGET_DIR):
	rsync -av $(TEMPLATE_TARGET_DIR) $(BOOSTER_TARGET_DIR)

patches:
	cd patches && bash patch.sh
