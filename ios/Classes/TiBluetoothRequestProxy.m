/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothRequestProxy.h"

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

@end
