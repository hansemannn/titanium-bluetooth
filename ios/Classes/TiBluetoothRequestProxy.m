/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothRequestProxy.h"
#import "TiBluetoothCentralProxy.h"
#import "TiBluetoothCharacteristicProxy.h"
#import "TiBlob.h"

@implementation TiBluetoothRequestProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andRequest:(CBATTRequest *)_request
{
    if (self = [super _initWithPageContext:context]) {
        request = _request;
    }
    
    return self;
}

- (CBATTRequest *)request
{
    return request;
}

#pragma mark Public APIs

- (TiBluetoothCentralProxy *)central
{
    return [[TiBluetoothCentralProxy alloc] _initWithPageContext:[self pageContext] andCentral:request.central];
}

- (TiBluetoothCharacteristicProxy *)characteristic
{
    return [[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:request.characteristic];
}

- (NSNumber *)offset
{
    return NUMUINTEGER(request.offset);
}

- (TiBlob *)value
{
    return [[TiBlob alloc] _initWithPageContext:[self pageContext] andData:request.value mimetype:@"text/plain"];
}

@end
