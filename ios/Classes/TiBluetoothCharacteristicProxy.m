/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothCharacteristicProxy.h"
#import "TiBlob.h"
#import "TiBluetoothDescriptorProxy.h"
#import "TiBluetoothServiceProxy.h"
#import "TiUtils.h"

@implementation TiBluetoothCharacteristicProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andCharacteristic:(CBCharacteristic *)_characteristic
{
  if ([super _initWithPageContext:[self pageContext]]) {
    characteristic = _characteristic;
  }

  return self;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andProperties:(id)args
{
  if (self = [super _initWithPageContext:context]) {
    id uuid = [args objectForKey:@"uuid"];
    id properties = [args objectForKey:@"properties"];
    id value = [args objectForKey:@"value"];
    id permissions = [args objectForKey:@"permissions"];

    characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]
                                                        properties:[TiUtils intValue:properties]
                                                             value:[(TiBlob *)value data]
                                                       permissions:[TiUtils intValue:permissions]];
  }

  return self;
}

- (CBCharacteristic *)characteristic
{
  return characteristic;
}

#pragma mark Public API's

- (TiBluetoothServiceProxy *)service
{
  return [[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:characteristic.service];
}

- (NSNumber *)properties
{
  return NUMUINTEGER(characteristic.properties);
}

- (NSNumber *)isNotifying
{
  return NUMBOOL(characteristic.isNotifying);
}

- (NSArray *)descriptors
{
  return [self arrayFromDescriptors:characteristic.descriptors];
}

- (TiBlob *)value
{
  return [[TiBlob alloc] _initWithPageContext:[self pageContext] andData:characteristic.value mimetype:@"text/plain"];
}

- (NSString *)uuid
{
  return characteristic.UUID.UUIDString;
}

#pragma mark Utilities

- (NSArray *)arrayFromDescriptors:(NSArray<CBDescriptor *> *)descriptors
{
  NSMutableArray *result = [NSMutableArray array];

  for (CBDescriptor *descriptor in descriptors) {
    [result addObject:[[TiBluetoothDescriptorProxy alloc] _initWithPageContext:[self pageContext] andDescriptor:descriptor]];
  }

  return result;
}

@end
