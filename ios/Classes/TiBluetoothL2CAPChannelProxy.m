/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#if IS_XCODE_9

#import "TiBluetoothL2CAPChannelProxy.h"

@implementation TiBluetoothL2CAPChannelProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andChannel:(CBL2CAPChannel *)channel
{
  if ([super _initWithPageContext:[self pageContext]]) {
    _channel = channel;
  }
  
  return self;
}

@end

#endif
