/**
 * Axway Titanium
 * Copyright (c) 2009-present by Axway Appcelerator. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothBeaconManagerProxy.h"
#import "TiApp.h"

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

- (void)_configure
{
  [super _configure];
  [[TiApp app] registerApplicationDelegate:self];
}

- (void)_destroy
{
  [super _destroy];

  [[TiApp app] unregisterApplicationDelegate:self];
  
  if (_locationManager != nil) {
    _locationManager.delegate = nil;
  }
}

#pragma mark Public APIs

- (void)requestAlwaysAuthorization:(id)callback
{
  ENSURE_SINGLE_ARG(callback, KrollCallback);
  _authorizationCallback = callback;

  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
    [_authorizationCallback call:@[@{ @"success": @(YES) }] thisObject:self];
    _authorizationCallback = nil;
  } else {
    [[self locationManager] requestAlwaysAuthorization];
  }
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
  if (_authorizationCallback != nil) {
    [_authorizationCallback call:@[@{ @"success": @(status == kCLAuthorizationStatusAuthorizedAlways) }] thisObject:self];
    _authorizationCallback = nil;
  }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
  NSMutableArray<NSDictionary<NSString *, id> *> *mappedBeacons = [NSMutableArray arrayWithCapacity:beacons.count];

  for (CLBeacon *beacon in beacons) {
    [mappedBeacons addObject:@{
      @"uuid": beacon.UUID.UUIDString,
      @"proximity": @(beacon.proximity),
      @"timestamp": beacon.timestamp,
      @"major": beacon.major,
      @"minor": beacon.minor,
    }];
  }

  if (mappedBeacons.count > 0) {
    [self fireEvent:@"didRangeBeacons" withObject:@{ @"beacons": mappedBeacons }];
  }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
  [self fireEvent:@"didEnterRegion" withObject:@{ @"region": @{ @"uuid": region.identifier } }];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  [self fireEvent:@"didExitRegion" withObject:@{ @"region": @{ @"uuid": region.identifier } }];
}

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
{
  if ([launchOptions objectForKey:@"UIApplicationLaunchOptionsLocationKey"]) {
    [self fireEvent:@"applicationOpenedFromLocation"];
  }

  return YES;
}

@end
