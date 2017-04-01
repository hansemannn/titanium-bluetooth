/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothBeaconRegionProxy.h"
#import "TiBluetoothUtils.h"
#import "TiUtils.h"

@implementation TiBluetoothBeaconRegionProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andBeaconRegion:(CLBeaconRegion *)__beaconRegion
{
    if ([super _initWithPageContext:[self pageContext]]) {
        _beaconRegion = __beaconRegion;
        _measuredPower = nil;
    }
    
    return self;
}
    
- (CLBeaconRegion *)beaconRegion
{
    return _beaconRegion;
}

#pragma mark Public API's

- (NSNumber *)measuredPower
{
    return _measuredPower;
}

@end
