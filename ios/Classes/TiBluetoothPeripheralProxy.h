/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface TiBluetoothPeripheralProxy : TiProxy <CBPeripheralDelegate> {
  CBPeripheral *_peripheral;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andPeripheral:(CBPeripheral *)__peripheral;
- (CBPeripheral *)peripheral;

@end
