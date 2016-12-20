/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothPeripheralProxy.h"
#import "TiBluetoothServiceProxy.h"
#import "TiBluetoothCharacteristicProxy.h"
#import "TiBluetoothDescriptorProxy.h"
#import "TiBluetoothUtils.h"
#import "TiUtils.h"

@implementation TiBluetoothPeripheralProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andPeripheral:(CBPeripheral*)_peripheral
{
    if ([super _initWithPageContext:[self pageContext]]) {
        peripheral = _peripheral;
    }
    
    return self;
}
    
- (CBPeripheral*)peripheral
{
    return peripheral;
}

#pragma mark Public API's

- (id)name
{
    return peripheral.name;
}
    
- (id)rssi
{
    return NUMINT(peripheral.RSSI);
}
    
- (id)state
{
    return NUMINT(peripheral.state);
}
    
- (id)services
{
    return [self arrayFromServices:peripheral.services];
}

- (void)readRSSI:(id)unused
{
    [peripheral readRSSI];
}

- (void)discoverServices:(id)args
{
    [peripheral discoverServices:[TiBluetoothUtils UUIDArrayFromStringArray:args]];
}

- (void)discoverIncludedServicesForService:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    id includedServices = [args objectAtIndex:0];
    id service = [args objectAtIndex:1];
    
    ENSURE_TYPE(includedServices, NSArray);
    ENSURE_TYPE(service, TiBluetoothServiceProxy);
    
    [peripheral discoverIncludedServices:[TiBluetoothUtils UUIDArrayFromStringArray:includedServices]
                              forService:[(TiBluetoothServiceProxy *)service service]];
}

- (void)discoverCharacteristicsForService:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    id characteristics = [args objectAtIndex:0];
    id service = [args objectAtIndex:1];
    
    ENSURE_TYPE(characteristics, NSArray);
    ENSURE_TYPE(service, TiBluetoothServiceProxy);

    [peripheral discoverCharacteristics:[TiBluetoothUtils UUIDArrayFromStringArray:characteristics]
                             forService:[(TiBluetoothServiceProxy *)service service]];
}

- (void)readValueForCharacteristic:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothCharacteristicProxy);
    
    [peripheral readValueForCharacteristic:[(TiBluetoothCharacteristicProxy*)value characteristic]];
}

- (id)maximumWriteValueLengthForType:(id)value
{
    return NUMUINTEGER([peripheral maximumWriteValueLengthForType:[TiUtils intValue:value]]);
}

- (void)writeValueForCharacteristicWithType:(id)args
{
    ENSURE_ARG_COUNT(args, 3);
    
    id value = [args objectAtIndex:0];
    id characteristic = [args objectAtIndex:1];
    id type = [args objectAtIndex:2];
    
    ENSURE_TYPE(value, TiBlob);
    ENSURE_TYPE(characteristic, TiBluetoothCharacteristicProxy);
    ENSURE_TYPE(type, NSNumber);

    
    [peripheral writeValue:[(TiBlob*)value data]
         forCharacteristic:[(TiBluetoothCharacteristicProxy*)characteristic characteristic]
                      type:[TiUtils intValue:type]];
}

- (void)setNotifyValueForCharacteristic:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    id notifyValue = [args objectAtIndex:0];
    id characteristic = [args objectAtIndex:1];
    
    ENSURE_TYPE(notifyValue, NSNumber);
    ENSURE_TYPE(characteristic, TiBluetoothCharacteristicProxy);
    
    [peripheral setNotifyValue:[TiUtils boolValue:notifyValue]
             forCharacteristic:[(TiBluetoothCharacteristicProxy*)characteristic characteristic]];
}

- (void)discoverDescriptorsForCharacteristic:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothCharacteristicProxy);
    
    [peripheral discoverDescriptorsForCharacteristic:[(TiBluetoothCharacteristicProxy*)value characteristic]];
}

- (void)readValueForDescriptor:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothDescriptorProxy);

    [peripheral readValueForDescriptor:[(TiBluetoothDescriptorProxy*)value descriptor]];
}

- (void)writeValueForDescriptor:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    id value = [args objectAtIndex:0];
    id descriptor = [args objectAtIndex:1];
    
    ENSURE_TYPE(value, TiBlob);
    ENSURE_TYPE(descriptor, TiBluetoothDescriptorProxy);
    
    [peripheral writeValue:[(TiBlob*)value data]
             forDescriptor:[(TiBluetoothDescriptorProxy*)descriptor descriptor]];
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

@end
