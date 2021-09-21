//    Copyright (c) 2021 udevs
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, version 3.
//
//    This program is distributed in the hope that it will be useful, but
//    WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//    General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program. If not, see <http://www.gnu.org/licenses/>.

#include <Foundation/Foundation.h>
#include <HBLog.h>
#include <dlfcn.h>
#include <CSColorPicker/CSColorPicker.h>
#import "UIKitCore-Headers.h"

#define VPN_ACTIVE_COLOR [UIColor systemBlueColor]

typedef void* CTServerConnectionRef;
extern "C" CTServerConnectionRef _CTServerConnectionCreate(CFAllocatorRef, void *, void*);
extern "C" BOOL _CTServerConnectionCopyDualSimCapability(CTServerConnectionRef, CFNumberRef *);

static BOOL enabled;
static UIColor *activeColor;
static BOOL vpnActive;
static BOOL isCellular;
static BOOL isDualSimPreviouslyAvailable;

static BOOL isVPNConnected(){
	NSDictionary *proxySettings = CFBridgingRelease(CFNetworkCopySystemProxySettings());
	NSArray *keys = [proxySettings[@"__SCOPED__"] allKeys];
	for (NSString *key in keys){
		if ([key hasPrefix:@"tap"] || [key hasPrefix:@"tun"] || [key hasPrefix:@"ppp"] || [key hasPrefix:@"ipsec"] || [key hasPrefix:@"utun"]){
			return YES;
		}
	}
	return NO;
}

static BOOL isDualSimEnabled(){
	if (!dlsym(RTLD_DEFAULT, "_CTServerConnectionCopyDualSimCapability")) return NO;
	int n = 0;
	CTServerConnectionRef cn = _CTServerConnectionCreate(kCFAllocatorDefault, NULL, NULL);
	CFNumberRef dsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &n);
	_CTServerConnectionCopyDualSimCapability(cn, &dsRef);
	
	//0 - Disabled
	//1 - Enabled
	//2 - No Supported
	//3 - Unknown
	//Else - Invalud
	if (CFNumberCompare(dsRef, (CFNumberRef)(@1), NULL) == kCFCompareEqualTo){
		if (dsRef){
			CFRelease(dsRef);
		}
		return YES;
	}
	return NO;
}

%hook _UIStatusBar
-(id)initWithStyle:(long long)style{
	self = %orig;
	if (self){
		__weak _UIStatusBar *weakSelf = self;
		[[NSNotificationCenter defaultCenter] addObserverForName:@"SBVPNConnectionChangedNotification" object:nil queue:nil usingBlock:^(NSNotification *note){
			if (!enabled) return;
			SBWiFiManager *wifiManager = [%c(SBWiFiManager) sharedInstance];
			isCellular = ![wifiManager isPrimaryInterface];
			vpnActive = isVPNConnected();
			
			//Artificially disable and enable the item again to make it changes the tint across all scenes (apps), effectively remove the needs to hook onto every UIKit process
			SBStatusBarStateAggregator *stateAggregator = [%c(SBStatusBarStateAggregator) sharedInstance];
			for (_UIStatusBarDisplayItemState *itemState in weakSelf.displayItemStates.allValues){
				if ([itemState.item respondsToSelector:@selector(signalView)] && itemState.enabled){
					if (isCellular && [itemState.identifier.stringRepresentation hasPrefix:@"_UIStatusBarCellular"]){
						//4 - Primary
						//5 - Secondary (another SIM cellular)
						//6 - Service Item
						//7 - Secondary Service Item
						[stateAggregator _setItem:4 enabled:NO];
						[stateAggregator _notifyItemChanged:4];
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
							[stateAggregator _setItem:4 enabled:YES];
							[stateAggregator _notifyItemChanged:4];
						});
						if (isDualSimEnabled()){
							isDualSimPreviouslyAvailable = YES;
							[stateAggregator _setItem:7 enabled:NO];
							[stateAggregator _notifyItemChanged:7];
							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
								[stateAggregator _setItem:7 enabled:YES];
								[stateAggregator _notifyItemChanged:7];
							});
						}else if (isDualSimPreviouslyAvailable){
							[stateAggregator _setItem:7 enabled:YES];
							[stateAggregator _notifyItemChanged:7];
							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
								[stateAggregator _setItem:7 enabled:NO];
								[stateAggregator _notifyItemChanged:7];
							});
						}
						break;
					}else if ([itemState.identifier.stringRepresentation hasPrefix:@"_UIStatusBarWifi"]){
						//9 - Primary
						//10- Secondary
						[stateAggregator _setItem:9 enabled:NO];
						[stateAggregator _notifyItemChanged:9];
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
							[stateAggregator _setItem:9 enabled:YES];
							[stateAggregator _notifyItemChanged:9];
						});
						break;
					}
				}
			}
		}];
	}
	return self;
}
%end

%hook _UIStatusBarWifiSignalView
-(void)setActiveColor:(UIColor *)color{
	if (enabled && vpnActive && !isCellular){
		return %orig(activeColor);
	}
	%orig;
}
%end

%hook _UIStatusBarCellularSignalView
-(void)setActiveColor:(UIColor *)color{
	if (enabled && vpnActive && isCellular){
		return %orig(activeColor);
	}
	%orig;
}
%end

static id valueForKey(NSString *key, id defaultValue){
	CFStringRef appID = CFSTR("com.udevs.vpnindicator");
	CFPreferencesAppSynchronize(appID);
	
	CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList != NULL){
		BOOL containsKey = CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), (__bridge CFStringRef)key);
		CFRelease(keyList);
		if (!containsKey) return defaultValue;
		
		return CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key, appID));
	}
	return defaultValue;
}

static void reloadPrefs(){
	enabled = [valueForKey(@"enabled", @YES) boolValue];
	id activeColorVal = valueForKey(@"activeColor", nil);
	activeColor = activeColorVal ? [UIColor cscp_colorFromHexString:activeColorVal] : VPN_ACTIVE_COLOR;
	
}

%ctor{
	reloadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, CFSTR("com.udevs.vpnindicator.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
