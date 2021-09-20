TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = VPNIndicatorPrefs

VPNIndicatorPrefs_FILES = VIPRootListController.m
VPNIndicatorPrefs_FRAMEWORKS = UIKit
VPNIndicatorPrefs_PRIVATE_FRAMEWORKS = Preferences
VPNIndicatorPrefs_INSTALL_PATH = /Library/PreferenceBundles
VPNIndicatorPrefs_CFLAGS = -fobjc-arc
VPNIndicatorPrefs_LDFLAGS += -lCSColorPicker

include $(THEOS_MAKE_PATH)/bundle.mk
