/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothPeripheralProxy.h"
#import "TiBluetoothServiceProxy.h"

@implementation TiBluetoothPeripheralProxy

-(id)_initWithPageContext:(id<TiEvaluator>)context andPeripheral:(CBPeripheral*)_peripheral
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

-(id)name
{
    return peripheral.name;
}
    
-(id)rssi
{
    return NUMINT(peripheral.RSSI);
}
    
-(id)state
{
    return NUMINT(peripheral.state);
}
    
-(id)services
{
    return [self arrayFromServices:peripheral.services];
}


#pragma mark Utilities

-(NSArray*)arrayFromServices:(NSArray<CBService*>*)services
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBService *service in services) {
        [result addObject:[[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:service]];
    }
    
    return result;
}

@end
