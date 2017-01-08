/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothPeripheralManagerProxy.h"
#import "TiBluetoothCharacteristicProxy.h"
#import "TiBluetoothServiceProxy.h"
#import "TiBluetoothDescriptorProxy.h"
#import "TiBluetoothCentralProxy.h"
#import "TiBluetoothRequestProxy.h"
#import "TiUtils.h"
#import "TiBluetoothUtils.h"

@implementation TiBluetoothPeripheralManagerProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andProperties:(id)args
{
    if (self = [super _initWithPageContext:context]) {
        NSString *bluetoothPermissions = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSBluetoothPeripheralUsageDescription"];
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        NSNumber *showPowerAlert;
        NSString *restoreIdentifier;
        
        if(!bluetoothPermissions) {
            [self throwException:@"The NSBluetoothPeripheralUsageDescription key is required to interact with Bluetooth on iOS. Please add it to your plist and try it again." subreason:nil location:CODELOCATION];
            return;
        }
        
        ENSURE_ARG_OR_NIL_FOR_KEY(showPowerAlert, args, @"showPowerAlert", NSNumber);
        ENSURE_ARG_OR_NIL_FOR_KEY(restoreIdentifier, args, @"restoreIdentifier", NSString);
        
        if (showPowerAlert) {
            [options setObject:showPowerAlert forKey:CBPeripheralManagerOptionShowPowerAlertKey];
        }
        
        if (restoreIdentifier) {
            [options setObject:restoreIdentifier forKey:CBPeripheralManagerOptionRestoreIdentifierKey];
        }
        
        peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                    queue:dispatch_get_main_queue()
                                                                  options:options.count > 0 ? options : nil];
    }
    
    return self;
}

#pragma mark Public APIs

- (id)state
{
    return NUMINTEGER([peripheralManager state]);
}

- (id)isAdvertising
{
    return NUMBOOL([peripheralManager isAdvertising]);
}

- (void)startAdvertising:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    // FIXME: Handle CBAdvertisementDataServiceUUIDsKey and CBAdvertisementDataLocalNameKey
    [peripheralManager startAdvertising:nil];
}

- (void)stopAdvertising:(id)unused
{
    [peripheralManager stopAdvertising];
}

- (void)setDesiredConnectionLatencyForCentral:(id)args
{
    ENSURE_TYPE(args, NSArray);
    ENSURE_ARG_COUNT(args, 2);
    
    id latency = [args objectAtIndex:0];
    id central = [args objectAtIndex:1];
    
    ENSURE_TYPE(latency, NSNumber);
    ENSURE_TYPE(central, TiBluetoothCentralProxy);
    
    [peripheralManager setDesiredConnectionLatency:[TiUtils intValue:latency]
                                        forCentral:[(TiBluetoothCentralProxy *)central central]];
}

- (void)addService:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothServiceProxy);
    
    [peripheralManager addService:(CBMutableService *)[(TiBluetoothServiceProxy *)value service]];
}

- (void)removeService:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothServiceProxy);
    
    [peripheralManager removeService:(CBMutableService *)[(TiBluetoothServiceProxy *)value service]];
}

- (void)removeAllServices:(id)unused
{
    [peripheralManager removeAllServices];
}

- (void)respondToRequestWithResult:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    id request = [args objectAtIndex:0];
    id result = [args objectAtIndex:1];
    
    [peripheralManager respondToRequest:[(TiBluetoothRequestProxy *)request request]
                             withResult:[TiUtils intValue:result]];
}

- (void)updateValueForCharacteristicOnSubscribedCentrals:(id)args
{
    ENSURE_ARG_COUNT(args, 3);
    
    id value = [args objectAtIndex:0];
    id characteristic = [args objectAtIndex:1];
    id subscribedCentrals = [args objectAtIndex:2];
    
    ENSURE_TYPE(value, TiBlob);
    ENSURE_TYPE(characteristic, TiBluetoothCharacteristicProxy);
    ENSURE_TYPE(subscribedCentrals, NSArray);
    
    NSMutableArray *result = [NSMutableArray array];
    
    for (id subscribedCentral in subscribedCentrals) {
        ENSURE_TYPE(subscribedCentral, TiBluetoothCentralProxy)
        [result addObject:[(TiBluetoothCentralProxy *)subscribedCentral central]];
    }
    
    [peripheralManager updateValue:[(TiBlob *)value data]
                 forCharacteristic:(CBMutableCharacteristic *)[(TiBluetoothCharacteristicProxy *)characteristic characteristic]
              onSubscribedCentrals:result];
}

#pragma mark Delegates

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if ([self _hasListeners:@"didUpdateState"]) {
        [self fireEvent:@"didUpdateState" withObject:@{
            @"state":NUMINT(peripheral.state)
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *, id> *)dict
{
    if ([self _hasListeners:@"willRestoreState"]) {
        [self fireEvent:@"willRestoreState" withObject:@{
            @"state":NUMINT(peripheral.state)
        }];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error
{
    if ([self _hasListeners:@"didStartAdvertising"]) {
        [self fireEvent:@"didStartAdvertising" withObject:@{
            @"success": NUMBOOL(error == nil),
            @"error": [error localizedDescription] ?: [NSNull null]
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(nullable NSError *)error
{
    if ([self _hasListeners:@"didAddService"]) {
        [self fireEvent:@"didAddService" withObject:@{
            @"service":[[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:service],
            @"error": [error localizedDescription] ?: [NSNull null]
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    if ([self _hasListeners:@"didSubscribeToCharacteristic"]) {
        [self fireEvent:@"didSubscribeToCharacteristic" withObject:@{
            @"central": [[TiBluetoothCentralProxy alloc] _initWithPageContext:[self pageContext] andCentral:central],
            @"characteristic":[[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:characteristic]
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    if ([self _hasListeners:@"didUnsubscribeFromCharacteristic"]) {
        [self fireEvent:@"didUnsubscribeFromCharacteristic" withObject:@{
            @"central": [[TiBluetoothCentralProxy alloc] _initWithPageContext:[self pageContext] andCentral:central],
            @"characteristic":[[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:characteristic]
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request;
{
    if ([self _hasListeners:@"didReceiveReadRequest"]) {
        [self fireEvent:@"didReceiveReadRequest" withObject:@{
            @"request": [[TiBluetoothRequestProxy alloc] _initWithPageContext:[self pageContext] andRequest:request]
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    if ([self _hasListeners:@"didReceiveWriteRequests"]) {
        [self fireEvent:@"didReceiveWriteRequests" withObject:@{
            @"requests":[self arrayFromReadWriteRequests:requests]
        }];
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    if ([self _hasListeners:@"readyToUpdateSubscribers"]) {
        [self fireEvent:@"readyToUpdateSubscribers" withObject:nil];
    }
}

#pragma mark Utilities

- (NSArray *)arrayFromReadWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBATTRequest *request in requests) {
        [result addObject:[[TiBluetoothRequestProxy alloc] _initWithPageContext:[self pageContext] andRequest:request]];
    }
    
    return result;
}

@end
