# Inherit common toxic stuff
$(call inherit-product, vendor/toxic/config/common_mini.mk)

# Required toxic packages
PRODUCT_PACKAGES += \
    LatinIME

ifeq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
    PRODUCT_COPY_FILES += \
        vendor/toxic/prebuilt/common/bootanimation/800.zip:system/media/bootanimation.zip
endif
