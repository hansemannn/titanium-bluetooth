/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <CoreLocation/CoreLocation.h>

@interface TiBluetoothBeaconRegionProxy : TiProxy {
    CLBeaconRegion *_beaconRegion;
    NSNumber *_measuredPower;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andBeaconRegion:(CLBeaconRegion *)__beaconRegion;
- (CLBeaconRegion *)beaconRegion;
- (NSNumber *)measuredPower;

@end
