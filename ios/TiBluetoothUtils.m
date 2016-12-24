/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothUtils.h"
#import "TiUtils.h"

@implementation TiBluetoothUtils

+ (NSArray<CBUUID *> *)UUIDArrayFromStringArray:(NSArray<id>*)array
{
    NSMutableArray<CBUUID*> *result = [NSMutableArray array];
    
    for (id uuid in array) {
        ENSURE_TYPE(uuid, NSString);
        [result addObject:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]];
    }

    return result;
}

+ (NSArray<id> *)stringArrayFromUUIDArray:(NSArray<CBUUID *> *)array
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBUUID *uuid in array) {
        ENSURE_TYPE(uuid, CBUUID);
        [result addObject:[uuid UUIDString]];
    }
    
    return result;
}

@end
