/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothServiceProxy.h"
#import "TiBluetoothPeripheralProxy.h"
#import "TiBluetoothCharacteristicProxy.h"

@implementation TiBluetoothServiceProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andService:(CBService *)_service
{
    if ([super _initWithPageContext:[self pageContext]]) {
        service = _service;
    }
    
    return self;
}

- (CBService*)service
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
    return [[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:service.peripheral];
}
- (id)includedServices
{
    return [self arrayFromServices:service.includedServices];
}
- (id)characteristics
{
    return [self arrayFromCharacteristics:service.characteristics];
}

#pragma mark Utilties

- (NSArray*)arrayFromServices:(NSArray<CBService*>*)services
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBService *_service in services) {
        [result addObject:[[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:_service]];
    }
    
    return result;
}

- (NSArray*)arrayFromCharacteristics:(NSArray<CBCharacteristic*>*)characteristics
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBCharacteristic *characteristic in characteristics) {
        [result addObject:[[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:characteristic]];
    }
    
    return result;
}

@end
