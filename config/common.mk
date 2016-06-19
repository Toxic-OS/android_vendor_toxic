PRODUCT_BRAND ?= Toxic-OS

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/toxic/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/toxic/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/toxic/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

ifneq ($(TARGET_BUILD_VARIANT),user)
# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0
endif

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/toxic/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/toxic/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/toxic/prebuilt/common/bin/50-toxic.sh:system/addon.d/50-toxic.sh \
    vendor/toxic/prebuilt/common/bin/blacklist:system/addon.d/blacklist

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/toxic/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/toxic/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/toxic/prebuilt/common/bin/sysinit:system/bin/sysinit

ifneq ($(TARGET_BUILD_VARIANT),user)
# userinit support
PRODUCT_COPY_FILES += \
    vendor/toxic/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit
endif

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/toxic/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Copy over added mimetype supported in libcore.net.MimeUtils
PRODUCT_COPY_FILES += \
    vendor/toxic/prebuilt/common/lib/content-types.properties:system/lib/content-types.properties

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is CM!
PRODUCT_COPY_FILES += \
    vendor/toxic/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# Theme engine
include vendor/toxic/config/themes_common.mk

# CMSDK
include vendor/toxic/config/cmsdk_common.mk

# Required CM packages
PRODUCT_PACKAGES += \
    Development \
    BluetoothExt \
    Profiles

# Optional CM packages
PRODUCT_PACKAGES += \
    libemoji \
    Terminal

# Include librsjni explicitly to workaround GMS issue
PRODUCT_PACKAGES += \
    librsjni

# Custom CM packages
PRODUCT_PACKAGES += \
    Launcher3 \
    Trebuchet \
    AudioFX \
    CMWallpapers \
    CMFileManager \
    Eleven \
    LockClock \
    CMUpdater \
    CyanogenSetupWizard \
    CMSettingsProvider \
    ToxicOTA \
    ExactCalculator \
    LiveLockScreenService \
    WeatherProvider \
    DataUsageProvider

# Exchange support
PRODUCT_PACKAGES += \
    Exchange2

# Extra tools in CM
PRODUCT_PACKAGES += \
    libsepol \
    mke2fs \
    tune2fs \
    nano \
    htop \
    mkfs.ntfs \
    fsck.ntfs \
    mount.ntfs \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace \
    pigz

WITH_EXFAT ?= true
ifeq ($(WITH_EXFAT),true)
TARGET_USES_EXFAT := true
PRODUCT_PACKAGES += \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat
endif

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    procmem \
    procrank \
    su
endif

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

DEVICE_PACKAGE_OVERLAYS += vendor/toxic/overlay/common

PRODUCT_VERSION_MAJOR = Toxic-OS
PRODUCT_VERSION_MINOR = Alpha-0.1-MM
PRODUCT_VERSION_MAINTENANCE = 0-RC0 

# Set TOXIC_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef TOXIC_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "CM_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^TOXIC_||g')
        TOXIC_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(TOXIC_BUILDTYPE)),)
    TOXIC_BUILDTYPE :=
endif

ifdef TOXIC_BUILDTYPE
    ifneq ($(TOXIC_BUILDTYPE), SNAPSHOT)
        ifdef TOXIC_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            TOXIC_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from TOXIC_EXTRAVERSION
            TOXIC_EXTRAVERSION := $(shell echo $(TOXIC_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to TOXIC_EXTRAVERSION
            TOXIC_EXTRAVERSION := -$(TOXIC_EXTRAVERSION)
        endif
    else
        ifndef TOXIC_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            TOXIC_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from TOXIC_EXTRAVERSION
            TOXIC_EXTRAVERSION := $(shell echo $(TOXIC_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to TOXIC_EXTRAVERSION
            TOXIC_EXTRAVERSION := -$(TOXIC_EXTRAVERSION)
        endif
    endif
else
    # If TOXIC_BUILDTYPE is not defined, set to UNOFFICIAL
    TOXIC_BUILDTYPE := UNOFFICIAL
    TOXIC_EXTRAVERSION :=
endif

ifeq ($(TOXIC_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        TOXIC_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(TOXIC_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        TOXIC_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(TOXIC_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            TOXIC_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(TOXIC_BUILD)
        else
            TOXIC_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(TOXIC_BUILD)
        endif
    endif
else
    TOXIC_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(TOXIC_BUILDTYPE)$(TOXIC_EXTRAVERSION)-$(TOXIC_BUILD)
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.toxic.version=$(TOXIC_VERSION) \
  ro.toxic.releasetype=$(TOXIC_BUILDTYPE) \
  ro.modversion=$(TOXIC_VERSION) \
  ro.cmlegal.url=https://cyngn.com/legal/privacy-policy

-include vendor/cm-priv/keys/keys.mk

TOXIC_DISPLAY_VERSION := $(TOXIC_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
  ifneq ($(TOXIC_BUILDTYPE), UNOFFICIAL)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
      ifneq ($(TOXIC_EXTRAVERSION),)
        # Remove leading dash from TOXIC_EXTRAVERSION
        TOXIC_EXTRAVERSION := $(shell echo $(TOXIC_EXTRAVERSION) | sed 's/-//')
        TARGET_VENDOR_RELEASE_BUILD_ID := $(TOXIC_EXTRAVERSION)
      else
        TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
      endif
    else
      TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
    endif
    TOXIC_DISPLAY_VERSION=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)
  endif
endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.toxic.display.version=$(TOXIC_DISPLAY_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
