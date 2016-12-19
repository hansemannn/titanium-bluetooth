/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothPeripheralProxy.h"
#import "TiBluetoothServiceProxy.h"
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
    NSMutableArray<CBUUID*> *uuids = [NSMutableArray array];
    
    for (id uuid in args) {
        ENSURE_TYPE(uuid, NSString);
        [uuids addObject:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]];
    }

    [peripheral discoverServices:uuids];
}

// TODO: Implement other CBPeripheral methods

- (void)discoverIncludedServicesForService:(id)args
{
    
}

- (void)discoverCharacteristicsForService:(id)args
{
    
}

- (void)readValueForCharacteristic:(id)value
{
    
}

- (id)maximumWriteValueLengthForType:(id)value
{
    
}

- (void)writeValueForCharacteristicWithType:(id)args
{
    
}

- (void)setNotifyValueForCharacteristic:(id)args
{
    
}

- (void)discoverDescriptorsForCharacteristic:(id)value
{
    
}

- (void)readValueForDescriptor:(id)value
{
    
}

- (void)writeValueForDescriptor:(id)args
{
    
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
