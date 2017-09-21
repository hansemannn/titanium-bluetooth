/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#if IS_XCODE_9

#import "TiProxy.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface TiBluetoothL2CAPChannelProxy : TiProxy {
  CBL2CAPChannel *_channel;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andChannel:(CBL2CAPChannel *)channel;

@end

#endif
