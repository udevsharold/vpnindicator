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
#import "UIKitCore-Headers.h"

#define VPN_ACTIVE_COLOR [UIColor systemBlueColor]

static BOOL vpnActive;
static BOOL isCellular;

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

%hook _UIStatusBar
-(id)initWithStyle:(long long)style{
	self = %orig;
	if (self){
		__weak _UIStatusBar *weakSelf = self;
		[[NSNotificationCenter defaultCenter] addObserverForName:@"SBVPNConnectionChangedNotification" object:nil queue:nil usingBlock:^(NSNotification *note){
			SBWiFiManager *wifiManager = [%c(SBWiFiManager) sharedInstance];
			isCellular = ![wifiManager isPrimaryInterface];
			vpnActive = isVPNConnected();
			
			//Artificially disable and enable the item again to make it changes the tint across all scenes (apps), effectively remove the needs to hook onto every UIKit process
			SBStatusBarStateAggregator *stateAggregator = [%c(SBStatusBarStateAggregator) sharedInstance];
			for (_UIStatusBarDisplayItemState *itemState in weakSelf.displayItemStates.allValues){
				if ([itemState.item respondsToSelector:@selector(signalView)] && itemState.enabled){
					HBLogDebug(@"itemState.identifier.stringRepresentation: %@", itemState.identifier.stringRepresentation);
					if (isCellular && [itemState.identifier.stringRepresentation hasPrefix:@"_UIStatusBarCellular"]){
						//4 - Primary
						//5 - Secondary (another SIM cellular)
						[stateAggregator _setItem:4 enabled:NO];
						[stateAggregator _notifyItemChanged:4];
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
							[stateAggregator _setItem:4 enabled:YES];
							[stateAggregator _notifyItemChanged:4];
						});
						
					}else if ([itemState.identifier.stringRepresentation hasPrefix:@"_UIStatusBarWifi"]){
						//9 - Primary
						//10- Secondary
						[stateAggregator _setItem:9 enabled:NO];
						[stateAggregator _notifyItemChanged:9];
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
							[stateAggregator _setItem:9 enabled:YES];
							[stateAggregator _notifyItemChanged:9];
						});
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
	if (vpnActive && !isCellular){
		return %orig(VPN_ACTIVE_COLOR);
	}
	%orig;
}
%end

%hook _UIStatusBarCellularSignalView
-(void)setActiveColor:(UIColor *)color{
	if (vpnActive && isCellular){
		return %orig(VPN_ACTIVE_COLOR);
	}
	%orig;
}
%end
