# Inherit common toxic stuff
$(call inherit-product, vendor/toxic/config/common.mk)

PRODUCT_SIZE := mini

# Include toxic audio files
include vendor/toxic/config/toxic_audio.mk

# Default notification/alarm sounds
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.notification_sound=Argon.ogg \
    ro.config.alarm_alert=Helium.ogg

