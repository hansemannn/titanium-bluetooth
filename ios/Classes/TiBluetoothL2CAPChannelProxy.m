/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothL2CAPChannelProxy.h"

@implementation TiBluetoothL2CAPChannelProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andChannel:(CBL2CAPChannel *)channel
{
  if ([super _initWithPageContext:[self pageContext]]) {
    _channel = channel;
  }

  return self;
}

- (NSString *)peer
{
  return _channel.peer.identifier.UUIDString;
}

- (NSNumber *)PSM
{
  return NUMUINT(_channel.PSM);
}

// TODO: Expose inputStream / outputStream as well?
//
// Need to set the NSInputStream / NSOutputStream delegate first
// and then process the data-stream to be wrapped into a Ti.Blob

@end
