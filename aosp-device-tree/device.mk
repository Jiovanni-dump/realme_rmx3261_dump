#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)

PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-impl.recovery \
    android.hardware.boot@1.2-service

PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script

# API levels
PRODUCT_SHIPPING_API_LEVEL := 30

# fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl-mock \
    fastbootd

# Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Product characteristics
PRODUCT_CHARACTERISTICS := default

# Rootdir
PRODUCT_PACKAGES += \
    log_to_csv.sh \
    loading.sh \
    para.sh \
    total.sh \
    engineer_vendor_shell.sh \

PRODUCT_PACKAGES += \
    fstab.S19610AA1 \
    init.S19610AA1.rc \
    init.S19610AA1.usb.rc \
    init.cali.rc \
    init.factorytest.rc \
    init.ram.rc \
    init.storage.rc \
    init.ums512_1h10.rc \
    init.ums512_1h10.usb.rc \
    init.ums512_1h10_go.rc \
    init.ums512_1h10_go.usb.rc \
    init.ums512_20c10.rc \
    init.ums512_20c10.usb.rc \
    init.ums512_2h10.rc \
    init.ums512_2h10.usb.rc \
    init.recovery.S19610AA1.rc \
    init.recovery.common.rc \
    init.recovery.ums512_1h10.rc \
    init.recovery.ums512_1h10_go.rc \
    init.recovery.ums512_20c10.rc \
    init.recovery.ums512_2h10.rc \
    ueventd.S19610AA1.rc \
    ueventd.ums512_1h10.rc \
    ueventd.ums512_1h10_go.rc \
    ueventd.ums512_20c10.rc \
    ueventd.ums512_2h10.rc \

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.S19610AA1:$(TARGET_VENDOR_RAMDISK_OUT)/first_stage_ramdisk/fstab.S19610AA1

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Inherit the proprietary files
$(call inherit-product, vendor/realme/RMX3261/RMX3261-vendor.mk)
