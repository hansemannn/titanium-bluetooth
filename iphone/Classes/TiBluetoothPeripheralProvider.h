/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

@class TiBluetoothPeripheralProxy;
@class CBPeripheral;

@interface TiBluetoothPeripheralProvider : NSObject {
    NSMutableArray<TiBluetoothPeripheralProxy *> *peripherals;
}

- (instancetype)init NS_UNAVAILABLE;

+ (id)sharedInstance;

- (NSArray<TiBluetoothPeripheralProxy *> *)peripherals;

- (BOOL)hasPeripheral:(TiBluetoothPeripheralProxy *)peripheral;

- (void)addPeripheral:(TiBluetoothPeripheralProxy *)peripheral;

- (void)removePeripheral:(TiBluetoothPeripheralProxy *)peripheral;

- (TiBluetoothPeripheralProxy *)peripheralProxyFromPeripheral:(CBPeripheral *)peripheral;

@end
