/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothServiceProxy.h"
#import "TiBluetoothCharacteristicProvider.h"
#import "TiBluetoothCharacteristicProxy.h"
#import "TiBluetoothPeripheralProvider.h"
#import "TiBluetoothPeripheralProxy.h"
#import "TiUtils.h"

@implementation TiBluetoothServiceProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andService:(CBService *)_service
{
  if ([super _initWithPageContext:[self pageContext]]) {
    service = (CBMutableService *)_service;
  }

  return self;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andProperties:(id)args
{
  if (self = [super _initWithPageContext:context]) {
    id uuid = [args objectForKey:@"uuid"];
    id primary = [args objectForKey:@"primary"];
    id characteristics = [args objectForKey:@"characteristics"];
    id includedServices = [args objectForKey:@"includedServices"];

    service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]
                                             primary:[TiUtils boolValue:primary]];

    if (characteristics) {
      NSMutableArray *result = [NSMutableArray array];

      for (id characteristic in characteristics) {
        ENSURE_TYPE(characteristic, TiBluetoothCharacteristicProxy);
        [result addObject:[(TiBluetoothCharacteristicProxy *)characteristic characteristic]];
      }

      [service setCharacteristics:result];
    }

    if (includedServices) {
      NSMutableArray *result = [NSMutableArray array];

      for (id includedService in includedServices) {
        ENSURE_TYPE(includedService, TiBluetoothServiceProxy);
        [result addObject:[(TiBluetoothServiceProxy *)includedService service]];
      }

      [service setIncludedServices:result];
    }
  }

  return self;
}

- (CBService *)service
{
  return service;
}

#pragma mark Public API's

- (id)isPrimary
{
  return NUMBOOL(service.isPrimary);
}

- (id)peripheral
{
  return [self peripheralProxyFromPeripheral:service.peripheral];
}

- (id)includedServices
{
  return [self arrayFromServices:service.includedServices];
}

- (id)characteristics
{
  return [self arrayFromCharacteristics:service.characteristics];
}

- (id)uuid
{
  return service.UUID.UUIDString;
}

#pragma mark Utilties

- (TiBluetoothPeripheralProxy *)peripheralProxyFromPeripheral:(CBPeripheral *)peripheral
{
  __block TiBluetoothPeripheralProxy *result = [[TiBluetoothPeripheralProvider sharedInstance] peripheralProxyFromPeripheral:peripheral];

  if (!result) {
    NSLog(@"[DEBUG] Could not find cached instance of Ti.Bluetooth.Peripheral proxy. Adding and returning it now.");

    result = [[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral];
    [[TiBluetoothPeripheralProvider sharedInstance] addPeripheral:result];
  }

  return result;
}

- (TiBluetoothCharacteristicProxy *)characteristicProxyFromCharacteristic:(CBCharacteristic *)characteristic
{
  __block TiBluetoothCharacteristicProxy *result = [[TiBluetoothCharacteristicProvider sharedInstance] characteristicProxyFromCharacteristic:characteristic];

  if (!result) {
    NSLog(@"[DEBUG] Could not find cached instance of Ti.Bluetooth.Characteristic proxy. Adding and returning it now.");

    result = [[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:characteristic];
    [[TiBluetoothCharacteristicProvider sharedInstance] addCharacteristic:result];
  }

  return result;
}

- (NSArray *)arrayFromServices:(NSArray<CBService *> *)services
{
  NSMutableArray *result = [NSMutableArray array];

  for (CBService *_service in services) {
    [result addObject:[[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:(CBService *)_service]];
  }

  return result;
}

- (NSArray *)arrayFromCharacteristics:(NSArray<CBCharacteristic *> *)characteristics
{
  NSMutableArray *result = [NSMutableArray array];

  for (CBCharacteristic *characteristic in characteristics) {
    [result addObject:[self characteristicProxyFromCharacteristic:characteristic]];
  }

  return result;
}

@end
