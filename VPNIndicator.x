#include <Foundation/Foundation.h>
#include <HBLog.h>

#define VPN_ACIVE_COLOR [UIColor systemBlueColor]

@interface _UIStatusBarItemUpdate : NSObject
@property (assign,nonatomic) BOOL enabilityChanged;
@property (assign,nonatomic) BOOL enabled;
@end

@interface _UIStatusBarItem : NSObject
-(void)setNeedsUpdate;
-(id)_applyUpdate:(_UIStatusBarItemUpdate *)arg1 toDisplayItem:(id)arg2 ;
-(void)updatedDisplayItemsWithData:(id)arg1 ;
@end

@interface _UIStatusBarPersistentAnimationView : UIView
@end

@interface _UIStatusBarCycleAnimation : NSObject
@property (assign,nonatomic) BOOL stopsAfterReversing;
-(void)_stopAnimations;
@end

@interface _UIStatusBarSignalView : _UIStatusBarPersistentAnimationView
@property (nonatomic,copy) UIColor * activeColor;
@property (nonatomic,copy) UIColor * inactiveColor;
@property (assign,nonatomic) long long numberOfActiveBars;
@property (assign,nonatomic) long long signalMode;
@property (nonatomic,retain) _UIStatusBarCycleAnimation * cycleAnimation;
-(void)_colorsDidChange;
-(void)_updateBars;
-(void)_updateActiveBars;
-(void)_updateFromMode:(long long)arg1 ;
-(void)_updateCycleAnimationNow;
@end


@interface _UIStatusBarCellularSignalView : _UIStatusBarSignalView
@end

@interface _UIStatusBarWifiSignalView : _UIStatusBarSignalView
@end

@interface _UIStatusBarCellularItem : _UIStatusBarItem
@property (nonatomic,retain) _UIStatusBarCellularSignalView * signalView;
@end

@interface _UIStatusBarWifiItem : _UIStatusBarItem
@property (nonatomic,retain) _UIStatusBarWifiSignalView * signalView;
@end

@interface _UIStatusBarIdentifier : NSObject
@end

@interface _UIStatusBarStyleAttributes : NSObject
@property (nonatomic,copy) UIColor * imageTintColor;
@property (nonatomic,copy) UIColor * textColor;
@end

@interface _UIStatusBar : UIView
@property (nonatomic,copy) UIColor *foregroundColor;
@property (nonatomic,retain) NSMutableDictionary <_UIStatusBarIdentifier *, id>* items;
@property (nonatomic,retain) _UIStatusBarStyleAttributes * styleAttributes;
@property (assign,nonatomic) long long mode;-(void)_updateRegionItems;
@end

@interface SBStatusBarStateAggregator : NSObject
+(id)sharedInstance;
-(void)updateStatusBarItem:(int)arg1 ;
-(void)_notifyItemChanged:(int)arg1 ;
-(void)_updateSignalStrengthItem;
-(BOOL)_setItem:(int)arg1 enabled:(BOOL)arg2 ;
-(void)_notifyItemChanged:(int)arg1 ;
-(void)beginCoalescentBlock;
-(void)_updateTetheringState;
-(void)_resetTimeItemFormatter;
-(void)_notifyNonItemDataChanged;
-(void)endCoalescentBlock;
-(BOOL)_setItem:(int)arg1 enabled:(BOOL)arg2 ;
-(BOOL)_setItem:(int)arg1 enabled:(BOOL)arg2 inList:(BOOL*)arg3 itemPostState:(unsigned long long*)arg4 ;
@end

@interface SBWiFiManager : NSObject
+(id)sharedInstance;
-(void)_updateSignalStrengthFromRawRSSI:(int)arg1 andScaledRSSI:(float)arg2 ;
-(BOOL)isPrimaryInterface;
@end



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
		[[NSNotificationCenter defaultCenter] addObserverForName:@"SBVPNConnectionChangedNotification" object:nil queue:nil usingBlock:^(NSNotification *note){
			SBWiFiManager *wifiManager = [%c(SBWiFiManager) sharedInstance];
			isCellular = ![wifiManager isPrimaryInterface];
			vpnActive = isVPNConnected();
			if (!vpnActive){
				SBStatusBarStateAggregator *stateAggregator = [%c(SBStatusBarStateAggregator) sharedInstance];
				if (isCellular){
					[stateAggregator _setItem:4 enabled:NO];
					[stateAggregator _notifyItemChanged:4];
					[stateAggregator _setItem:4 enabled:YES];
					[stateAggregator _notifyItemChanged:4];
				}else{
					[stateAggregator _setItem:9 enabled:NO];
					[stateAggregator _notifyItemChanged:9];
					[stateAggregator _setItem:9 enabled:YES];
					[stateAggregator _notifyItemChanged:9];
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
		return %orig(VPN_ACIVE_COLOR);
	}
	%orig;
}
%end

%hook _UIStatusBarCellularSignalView
-(void)setActiveColor:(UIColor *)color{
	if (vpnActive && isCellular){
		return %orig(VPN_ACIVE_COLOR);
	}
	%orig;
}
%end
