export ARCHS = arm64 arm64e

export DEBUG = 1
export FINALPACKAGE = 0

export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/

TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VPNIndicator

$(TWEAK_NAME)_FILES = $(wildcard *.xm)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit CFNetwork CoreTelephony
$(TWEAK_NAME)_LIBRARIES = CSColorPicker

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += vpnindicatorprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
