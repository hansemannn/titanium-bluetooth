/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothDescriptorProxy.h"
#import "TiBluetoothCharacteristicProxy.h"
#import "TiBluetoothCharacteristicProvider.h"
#import "TiUtils.h"
#import "TiBlob.h"

@implementation TiBluetoothDescriptorProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andDescriptor:(CBDescriptor *)_descriptor
{
    if ([super _initWithPageContext:[self pageContext]]) {
        descriptor = _descriptor;
    }
    
    return self;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andProperties:(id)args
{
    if (self = [super _initWithPageContext:context]) {
        id uuid = [args objectForKey:@"uuid"];
        id value = [args objectForKey:@"value"];
        
        descriptor = [[CBMutableDescriptor alloc] initWithType:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]] value:[(TiBlob *)value data]];
    }
    
    return self;
}

- (CBDescriptor *)descriptor
{
    return descriptor;
}

#pragma mark Public API's

- (id)characteristic
{
    return [self characteristicProxyFromCharacteristic:descriptor.characteristic];
}

- (id)value
{
    return descriptor.value;
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

@end
