/**
 * Axway Titanium
 * Copyright (c) 2009-present by Axway Appcelerator. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothBeaconManagerProxy.h"

@implementation TiBluetoothBeaconManagerProxy

- (CLLocationManager *)locationManager
{
  if (_locationManager == nil) {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.allowsBackgroundLocationUpdates = YES;
    _locationManager.pausesLocationUpdatesAutomatically = NO;
  }

  return _locationManager;;
}

- (void)_destroy
{
  [super _destroy];

  if (_locationManager != nil) {
    _locationManager.delegate = nil;
  }
}

#pragma mark Public APIs

- (void)requestAlwaysAuthorization:(id)unused
{
  [_locationManager requestAlwaysAuthorization];
}

- (void)startRangingBeaconsInRegion:(id)region
{
  ENSURE_SINGLE_ARG(region, NSDictionary);
  
    NSString *uuid = region[@"uuid"];
    NSNumber *minor = region[@"minor"];
    NSNumber *major = region[@"major"];
    NSString *identifier = region[@"identifier"];

    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                                                                  major:major.intValue
                                                                  minor:minor.intValue
                                                             identifier:identifier];

    beaconRegion.notifyOnEntry = YES;
    beaconRegion.notifyOnExit = NO;

    [[self locationManager] startMonitoringForRegion:beaconRegion];
    [[self locationManager] startRangingBeaconsInRegion:beaconRegion];
}

- (void)stopRangingBeaconsInRegion:(id)region
{
  ENSURE_SINGLE_ARG(region, NSDictionary);
  
    NSString *uuid = region[@"uuid"];
    NSNumber *minor = region[@"minor"];
    NSNumber *major = region[@"major"];
    NSString *identifier = region[@"identifier"];

    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                                                                  major:major.intValue
                                                                  minor:minor.intValue
                                                             identifier:identifier];
    
    [[self locationManager] stopMonitoringForRegion:beaconRegion];
    [[self locationManager] stopRangingBeaconsInRegion:beaconRegion];
}

- (NSNumber *)isBeaconRangingAvailable
{
  return @([CLLocationManager isMonitoringAvailableForClass:CLBeaconRegion.class] && CLLocationManager.isRangingAvailable);
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
  [self fireEvent:@"authorization" withObject:@{ @"success": @(status == kCLAuthorizationStatusAuthorizedAlways) }];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
  NSMutableArray<NSDictionary<NSString *, id> *> *mappedBeacons = [NSMutableArray arrayWithCapacity:beacons.count];

  for (CLBeacon *beacon in beacons) {
    [mappedBeacons addObject:@{
      @"uuid": beacon.UUID,
      @"proximity": @(beacon.proximity),
      @"timestamp": beacon.timestamp,
      @"major": beacon.major,
      @"minor": beacon.minor,
    }];
  }

  [self fireEvent:@"didRangeBeacons" withObject:@{ @"beacons": beacons }];
}

@end
