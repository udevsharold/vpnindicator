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

#define VPNINDICATOR_IDENTIFIER @"com.udevs.vpnindicator"
#define PREFS_CHANGED_NN @"com.udevs.vpnindicator.prefschanged"

@interface SBTelephonyManager : NSObject
+(instancetype)sharedTelephonyManager;
-(BOOL)isUsingVPNConnection;
@end
