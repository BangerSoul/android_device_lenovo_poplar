#
# Copyright (C) 2024-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Enforce the Lenovo MT8786 / TB311FU / XT2573-1 Little Kernel (LK) Boot Header v4 AVB invariant:
#   VBMeta Offset == HashDescriptor.image_size == 14,561,280 bytes (0xDE3000)
#   Total Partition Size == 33,554,432 bytes (32 MiB)

POPLAR_BOOT_VBMETA_OFFSET := 14561280

ifdef BUILDING_BOOT_IMAGE
ifneq ($(strip $(TARGET_NO_KERNEL)),true)

$(foreach b,$(INSTALLED_BOOTIMAGE_TARGET), $(eval $(call add-dependency,$(b),$(call bootimage-to-kernel,$(b)))))

define build_poplar_boot_unpacked
	$(MKBOOTIMG) --kernel $(2) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $(1)
	@cur_sz=$$(stat -c %s $(1)); \
	if [ $$cur_sz -gt $(POPLAR_BOOT_VBMETA_OFFSET) ]; then \
		echo "ERROR: $(1) ($$cur_sz B) exceeds LK 0xDE3000 boundary ($(POPLAR_BOOT_VBMETA_OFFSET) B)" >&2; \
		exit 1; \
	fi
	truncate -s $(POPLAR_BOOT_VBMETA_OFFSET) $(1)
endef

ifeq ($(BOARD_AVB_ENABLE),true)
define build_poplar_boot_avb
	$(call build_poplar_boot_unpacked,$(1),$(2))
	$(AVBTOOL) add_hash_footer \
		--image $(1) \
		$(call get-partition-size-argument,$(call get-bootimage-partition-size,$(1),boot)) \
		--salt `sha256sum "$(2)" | cut -d " " -f 1` \
		--partition_name boot $(INTERNAL_AVB_BOOT_SIGNING_ARGS) \
		$(BOARD_AVB_BOOT_ADD_HASH_FOOTER_ARGS)
endef

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(AVBTOOL) $(INTERNAL_BOOTIMAGE_FILES) $(BOARD_AVB_BOOT_KEY_PATH) $(BOOTIMAGE_EXTRA_DEPS)
	$(call pretty,"Target LK-aligned boot image: $@")
	$(call build_poplar_boot_avb,$@,$(call bootimage-to-kernel,$@))

.PHONY: bootimage-nodeps
bootimage-nodeps: $(MKBOOTIMG) $(AVBTOOL) $(BOARD_AVB_BOOT_KEY_PATH)
	@echo "make $@: ignoring dependencies"
	$(foreach b,$(INSTALLED_BOOTIMAGE_TARGET),$(call build_poplar_boot_avb,$(b),$(call bootimage-to-kernel,$(b))))
else
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(BOOTIMAGE_EXTRA_DEPS)
	$(call pretty,"Target LK-aligned boot image: $@")
	$(call build_poplar_boot_unpacked,$@,$(call bootimage-to-kernel,$@))

.PHONY: bootimage-nodeps
bootimage-nodeps: $(MKBOOTIMG)
	@echo "make $@: ignoring dependencies"
	$(foreach b,$(INSTALLED_BOOTIMAGE_TARGET),$(call build_poplar_boot_unpacked,$(b),$(call bootimage-to-kernel,$(b))))
endif

$(call declare-container-license-metadata,$(INSTALLED_BOOTIMAGE_TARGET),SPDX-license-identifier-GPL-2.0-only SPDX-license-identifier-Apache-2.0,restricted notice,$(BUILD_SYSTEM)/LINUX_KERNEL_COPYING build/soong/licenses/LICENSE,"Boot Image",boot)
$(call declare-container-license-deps,$(INSTALLED_BOOTIMAGE_TARGET),$(INTERNAL_BOOTIMAGE_FILES),$(PRODUCT_OUT)/:/)

UNMOUNTED_NOTICE_VENDOR_DEPS += $(INSTALLED_BOOTIMAGE_TARGET)

endif
endif

ifdef BUILDING_RECOVERY_IMAGE
ifneq ($(INSTALLED_RECOVERYIMAGE_TARGET),)
$(INSTALLED_RECOVERYIMAGE_TARGET): $(recoveryimage-deps) $(RECOVERYIMAGE_EXTRA_DEPS)
	$(call build-recoveryimage-target, $@, \
	  $(if $(filter true, $(BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE)),, $(recovery_kernel)))

.PHONY: recoveryimage-nodeps
recoveryimage-nodeps:
	@echo "make $@: ignoring dependencies"
	$(call build-recoveryimage-target, $(INSTALLED_RECOVERYIMAGE_TARGET), \
	  $(if $(filter true, $(BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE)),, $(recovery_kernel)))
endif
endif
