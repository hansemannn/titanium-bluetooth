/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface TiBluetoothRequestProxy : TiProxy {
    CBATTRequest *request;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andRequest:(CBATTRequest *)_request;
- (CBATTRequest *)request;

@end
