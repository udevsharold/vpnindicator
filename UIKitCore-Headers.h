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

@interface _UIStatusBarStyleAttributes : NSObject
@property (nonatomic,copy) UIColor * imageTintColor;
@property (nonatomic,copy) UIColor * textColor;
@end

@interface _UIStatusBarIdentifier : NSObject
@property (nonatomic,copy,readonly) NSString * stringRepresentation;
@property (nonatomic,copy) NSString * string;
@end

@interface _UIStatusBarDisplayItemState : NSObject
@property (nonatomic,copy) _UIStatusBarIdentifier * identifier;
@property (assign,nonatomic) _UIStatusBarItem * item;
@property (assign,nonatomic) long long enabilityStatus;
@property (assign,nonatomic) long long visibilityStatus;
@property (getter=isEnabled,nonatomic,readonly) BOOL enabled;
@end

@interface _UIStatusBar : UIView
@property (nonatomic,copy) UIColor *foregroundColor;
@property (nonatomic,retain) NSMutableDictionary <_UIStatusBarIdentifier *, id>* items;
@property (nonatomic,retain) NSMutableDictionary <id, _UIStatusBarDisplayItemState *>* displayItemStates;
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
