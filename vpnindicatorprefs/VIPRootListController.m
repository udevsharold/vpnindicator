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

#include "VIPRootListController.h"
#include <CSColorPicker/CSColorPicker.h>

@implementation VIPRootListController

-(void)viewDidLoad{
	[super viewDidLoad];
	
	
	CGRect frame = CGRectMake(0,0,self.table.bounds.size.width,170);
	CGRect Imageframe = CGRectMake(0,10,self.table.bounds.size.width,80);
	
	
	UIView *headerView = [[UIView alloc] initWithFrame:frame];
	headerView.backgroundColor = [UIColor colorWithRed: 0.40 green: 0.60 blue: 0.80 alpha: 1.00];
	
	
	UIImage *headerImage = [[UIImage alloc]
							initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/VPNIndicatorPrefs.bundle"] pathForResource:@"VPNIndicator512" ofType:@"png"]];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:Imageframe];
	[imageView setImage:headerImage];
	[imageView setContentMode:UIViewContentModeScaleAspectFit];
	[imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[headerView addSubview:imageView];
	
	CGRect labelFrame = CGRectMake(0,imageView.frame.origin.y + 90 ,self.table.bounds.size.width,80);
	UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40];
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:labelFrame];
	[headerLabel setText:@"VPNIndicator"];
	[headerLabel setFont:font];
	[headerLabel setTextColor:[UIColor blackColor]];
	headerLabel.textAlignment = NSTextAlignmentCenter;
	[headerLabel setContentMode:UIViewContentModeScaleAspectFit];
	[headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[headerView addSubview:headerLabel];
	
	self.table.tableHeaderView = headerView;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *rootSpecifiers = [[NSMutableArray alloc] init];
		
		//Tweak
		PSSpecifier *tweakEnabledGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"Tweak" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
		[tweakEnabledGroupSpec setProperty:@"No respring required." forKey:@"footerText"];
		[rootSpecifiers addObject:tweakEnabledGroupSpec];
		
		PSSpecifier *tweakEnabledSpec = [PSSpecifier preferenceSpecifierNamed:@"Enabled" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[tweakEnabledSpec setProperty:@"Enabled" forKey:@"label"];
		[tweakEnabledSpec setProperty:@"enabled" forKey:@"key"];
		[tweakEnabledSpec setProperty:@YES forKey:@"default"];
		[tweakEnabledSpec setProperty:@"com.udevs.vpnindicator" forKey:@"defaults"];
		[tweakEnabledSpec setProperty:@"com.udevs.vpnindicator.prefschanged" forKey:@"PostNotification"];
		[rootSpecifiers addObject:tweakEnabledSpec];
		
		//blank
		PSSpecifier *blankSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
		[rootSpecifiers addObject:blankSpecGroup];
		
		//activeColor
		PSSpecifier *activeColorSpec = [PSSpecifier preferenceSpecifierNamed:@"Active Color" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSLinkCell edit:nil];
		[activeColorSpec setProperty:NSClassFromString(@"CSColorDisplayCell") forKey:@"cellClass"];
		[activeColorSpec setProperty:@"com.udevs.vpnindicator" forKey:@"defaults"];
		[activeColorSpec setProperty:@"Color" forKey:@"label"];
		[activeColorSpec setProperty:@"activeColor" forKey:@"key"];
		[activeColorSpec setProperty:[UIColor cscp_hexStringFromColor:[UIColor systemBlueColor]] forKey:@"fallback"];
		[activeColorSpec setProperty:@"com.udevs.vpnindicator.prefschanged" forKey:@"PostNotification"];
		[rootSpecifiers addObject:activeColorSpec];

		//blank
		[rootSpecifiers addObject:blankSpecGroup];
		
		//Support Dev
		PSSpecifier *supportDevGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"Development" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
		[rootSpecifiers addObject:supportDevGroupSpec];
		
		PSSpecifier *supportDevSpec = [PSSpecifier preferenceSpecifierNamed:@"Support Development" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
		[supportDevSpec setProperty:@"Support Development" forKey:@"label"];
		[supportDevSpec setButtonAction:@selector(donation)];
		[supportDevSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/VPNIndicatorPrefs.bundle/PayPal.png"] forKey:@"iconImage"];
		[rootSpecifiers addObject:supportDevSpec];
		
		
		//Contact
		PSSpecifier *contactGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"Contact" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
		[rootSpecifiers addObject:contactGroupSpec];
		
		//Twitter
		PSSpecifier *twitterSpec = [PSSpecifier preferenceSpecifierNamed:@"Twitter" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
		[twitterSpec setProperty:@"Twitter" forKey:@"label"];
		[twitterSpec setButtonAction:@selector(twitter)];
		[twitterSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/VPNIndicatorPrefs.bundle/Twitter.png"] forKey:@"iconImage"];
		[rootSpecifiers addObject:twitterSpec];
		
		//Reddit
		PSSpecifier *redditSpec = [PSSpecifier preferenceSpecifierNamed:@"Reddit" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
		[redditSpec setProperty:@"Twitter" forKey:@"label"];
		[redditSpec setButtonAction:@selector(reddit)];
		[redditSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/VPNIndicatorPrefs.bundle/Reddit.png"] forKey:@"iconImage"];
		[rootSpecifiers addObject:redditSpec];
		
		//udevs
		PSSpecifier *createdByGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
		[createdByGroupSpec setProperty:@"Created by udevs" forKey:@"footerText"];
		[createdByGroupSpec setProperty:@1 forKey:@"footerAlignment"];
		[rootSpecifiers addObject:createdByGroupSpec];
		
		//blank
		[rootSpecifiers addObject:blankSpecGroup];
		[rootSpecifiers addObject:blankSpecGroup];
		[rootSpecifiers addObject:blankSpecGroup];
		
		
		_specifiers = rootSpecifiers;
	}
	
	return _specifiers;
}

- (void)donation {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/udevs"] options:@{} completionHandler:nil];
}

- (void)twitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/udevs9"] options:@{} completionHandler:nil];
}

- (void)reddit {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.reddit.com/user/h4roldj"] options:@{} completionHandler:nil];
}

@end
