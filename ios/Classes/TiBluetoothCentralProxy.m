/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothCentralProxy.h"

@implementation TiBluetoothCentralProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andCentral:(CBCentral *)_central
{
  if (self = [super _initWithPageContext:context]) {
    central = _central;
  }

  return self;
}

- (CBCentral *)central
{
  return central;
}

#pragma mark Public APIs

- (NSNumber *)maximumUpdateValueLength
{
  return @(central.maximumUpdateValueLength);
}

- (NSString *)identifier
{
  return central.identifier.UUIDString;
}

@end
