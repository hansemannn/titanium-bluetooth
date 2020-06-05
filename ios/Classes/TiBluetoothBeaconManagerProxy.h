/**
 * Axway Titanium
 * Copyright (c) 2009-present by Axway Appcelerator. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiProxy.h"
#import <CoreLocation/CoreLocation.h>

@interface TiBluetoothBeaconManagerProxy : TiProxy<CLLocationManagerDelegate, UIApplicationDelegate> {
  CLLocationManager *_locationManager;
}

@property(nonatomic, strong) KrollCallback *authorizationCallback;

- (void)requestAlwaysAuthorization:(id)unused;

- (void)startRangingBeaconsInRegion:(id)region;

- (void)stopRangingBeaconsInRegion:(id)region;

- (NSNumber *)isBeaconRangingAvailable;

@end
