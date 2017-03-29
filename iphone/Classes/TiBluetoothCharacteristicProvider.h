/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

@class TiBluetoothCharacteristicProxy;
@class CBCharacteristic;

@interface TiBluetoothCharacteristicProvider : NSObject {
    NSMutableArray<TiBluetoothCharacteristicProxy *> *characteristics;
}

- (instancetype)init NS_UNAVAILABLE;

+ (id)sharedInstance;

- (NSArray<TiBluetoothCharacteristicProxy *> *)characteristics;

- (BOOL)hasCharacteristic:(TiBluetoothCharacteristicProxy *)characteristic;

- (void)addCharacteristic:(TiBluetoothCharacteristicProxy *)characteristic;

- (void)removeCharacteristic:(TiBluetoothCharacteristicProxy *)characteristic;

- (TiBluetoothCharacteristicProxy *)characteristicProxyFromCharacteristic:(CBCharacteristic *)characteristic;

@end
