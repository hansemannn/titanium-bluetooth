/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface TiBluetoothCentralProxy : TiProxy {
    CBCentral *central;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andCentral:(CBCentral *)_central;
- (CBCentral *)central;

@end
