/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothDescriptorProxy.h"
#import "TiBluetoothCharacteristicProxy.h"

@implementation TiBluetoothDescriptorProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andDescriptor:(CBDescriptor*)_descriptor
{
    if ([super _initWithPageContext:[self pageContext]]) {
        descriptor = _descriptor;
    }
    
    return self;
}

- (CBDescriptor*)descriptor
{
    return descriptor;
}

#pragma mark Public API's

- (id)characteristic
{
    return [[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:descriptor.characteristic];
}

- (id)value
{
    return descriptor.value;
}

@end
