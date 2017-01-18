/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothPeripheralProvider.h"
#import "TiBluetoothPeripheralProxy.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation TiBluetoothPeripheralProvider

+ (id)sharedInstance
{
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (NSArray<TiBluetoothPeripheralProxy *> *)peripherals
{
    return (NSArray *)peripherals;
}

- (BOOL)hasPeripheral:(TiBluetoothPeripheralProxy *)peripheral
{
    return [peripherals containsObject:peripheral];
}

- (void)addPeripheral:(TiBluetoothPeripheralProxy *)peripheral
{
    [peripherals addObject:peripheral];
}

- (void)removePeripheral:(TiBluetoothPeripheralProxy *)peripheral;
{
    if ([peripherals containsObject:peripheral]) {
        NSLog(@"[ERROR] Trying to remove a peripheral with UUID = %@ that doesn't exist in the provider.");
        return;
    }
    
    [peripherals removeObject:peripheral];
}

- (TiBluetoothPeripheralProxy *)peripheralProxyFromPeripheral:(CBPeripheral *)peripheral
{
    __block TiBluetoothPeripheralProxy *result = nil;
    
    [peripherals enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if ([[(TiBluetoothPeripheralProxy *)object peripheral] identifier] == [peripheral identifier]) {
            result = object;
            *stop = YES;
            
        }
    }];
    
    return result;
}


@end
