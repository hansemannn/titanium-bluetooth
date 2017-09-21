/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothCharacteristicProvider.h"
#import "TiBluetoothCharacteristicProxy.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation TiBluetoothCharacteristicProvider

+ (id)sharedInstance
{
  static dispatch_once_t p = 0;

  __strong static id _sharedObject = nil;

  dispatch_once(&p, ^{
    _sharedObject = [[self alloc] init];
  });

  return _sharedObject;
}

- (NSArray<TiBluetoothCharacteristicProxy *> *)characteristics
{
  return (NSArray *)characteristics;
}

- (BOOL)hasCharacteristic:(TiBluetoothCharacteristicProxy *)characteristic
{
  return [characteristics containsObject:characteristic];
}

- (void)addCharacteristic:(TiBluetoothCharacteristicProxy *)peripheral
{
  [characteristics addObject:peripheral];
}

- (void)removeCharacteristic:(TiBluetoothCharacteristicProxy *)characteristic
{
  if ([characteristics containsObject:characteristic]) {
    NSLog(@"[ERROR] Trying to remove a characteristic that doesn't exist in the provider.");
    return;
  }

  [characteristics removeObject:characteristic];
}

- (TiBluetoothCharacteristicProxy *)characteristicProxyFromCharacteristic:(CBCharacteristic *)characteristic
{
  __block TiBluetoothCharacteristicProxy *result = nil;

  [characteristics enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
    if ([[(TiBluetoothCharacteristicProxy *)object characteristic] UUID] == [characteristic UUID]) {
      result = object;
      *stop = YES;
    }
  }];

  return result;
}

@end
