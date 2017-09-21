/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothUtils.h"
#import "TiUtils.h"

@implementation TiBluetoothUtils

+ (NSArray<CBUUID *> *_Nullable)CBUUIDArrayFromStringArray:(NSArray<id> *)array
{
  if (array == nil) {
    return nil;
  }

  NSMutableArray<CBUUID *> *result = [NSMutableArray array];

  for (id uuid in array) {
    ENSURE_TYPE(uuid, NSString);
    [result addObject:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]];
  }

  return result;
}

+ (NSArray<NSUUID *> *_Nullable)NSUUIDArrayFromStringArray:(NSArray<NSString *> *)array
{
  if (array == nil) {
    return nil;
  }

  NSMutableArray<NSUUID *> *result = [NSMutableArray array];

  for (NSString *uuid in array) {
    [result addObject:[[NSUUID alloc] initWithUUIDString:[TiUtils stringValue:uuid]]];
  }

  return result;
}

+ (NSArray<id> *_Nullable)stringArrayFromUUIDArray:(NSArray<CBUUID *> *)array
{
  if (array == nil) {
    return nil;
  }

  NSMutableArray *result = [NSMutableArray array];

  for (CBUUID *uuid in array) {
    ENSURE_TYPE(uuid, CBUUID);
    [result addObject:[uuid UUIDString]];
  }

  return result;
}

@end
