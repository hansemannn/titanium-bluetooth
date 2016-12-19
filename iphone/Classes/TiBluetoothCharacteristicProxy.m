/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothCharacteristicProxy.h"
#import "TiBluetoothServiceProxy.h"
#import "TiBluetoothDescriptorProxy.h"
#import "TiBlob.h"

@implementation TiBluetoothCharacteristicProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andCharacteristic:(CBCharacteristic*)_characteristic
{
    if ([super _initWithPageContext:[self pageContext]]) {
        characteristic = _characteristic;
    }
         
    return self;
}
    
- (CBCharacteristic*)characteristic
{
    return characteristic;
}
    
#pragma mark Public API's

- (id)service
{
    return [[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:characteristic.service];
}

- (id)properties
{
    return NUMUINTEGER(characteristic.properties);
}
    
- (id)isBroadcasted
{
    return NUMBOOL(characteristic.isBroadcasted);
}
    
- (id)isNotifying
{
    return NUMBOOL(characteristic.isNotifying);
}
    
- (id)descriptors
{
    return [self arrayFromDescriptors:characteristic.descriptors];
}
    
- (id)value
{
    return [[TiBlob alloc] initWithData:characteristic.value mimetype:@"text/plain"];
}



#pragma mark Utilities

- (NSArray*)arrayFromServices:(NSArray<CBService*>*)services
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBService *service in services) {
        [result addObject:[[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:service]];
    }
    
    return result;
}

- (NSArray*)arrayFromCharacteristics:(NSArray<CBCharacteristic*>*)characteristics
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBCharacteristic *_characteristic in characteristics) {
        [result addObject:[[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:_characteristic]];
    }
    
    return result;
}

- (NSArray*)arrayFromDescriptors:(NSArray<CBDescriptor*>*)descriptors
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBDescriptor *descriptor in descriptors) {
        [result addObject:[[TiBluetoothDescriptorProxy alloc] _initWithPageContext:[self pageContext] andDescriptor:descriptor]];
    }
    
    return result;
}

@end
