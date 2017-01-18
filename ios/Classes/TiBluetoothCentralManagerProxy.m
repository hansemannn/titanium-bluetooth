/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBluetoothCentralManagerProxy.h"
#import "TiUtils.h"
#import "TiBluetoothUtils.h"
#import "TiBluetoothPeripheralProvider.h"

#import "TiBluetoothPeripheralProxy.h"
#import "TiBluetoothCharacteristicProxy.h"

@implementation TiBluetoothCentralManagerProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andProperties:(id)args
{
    if (self = [super _initWithPageContext:context]) {
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        NSNumber *showPowerAlert;
        NSString *restoreIdentifier;
        
        ENSURE_ARG_OR_NIL_FOR_KEY(showPowerAlert, args, @"showPowerAlert", NSNumber);
        ENSURE_ARG_OR_NIL_FOR_KEY(restoreIdentifier, args, @"restoreIdentifier", NSString);
        
        if (showPowerAlert) {
            [options setObject:showPowerAlert
                        forKey:CBPeripheralManagerOptionShowPowerAlertKey];
        }
        
        if (restoreIdentifier) {
            [options setObject:restoreIdentifier
                        forKey:CBPeripheralManagerOptionRestoreIdentifierKey];
        }
        
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:options];
    }
    
    return self;
}

#pragma mark Public APIs

- (void)startScan:(id)unused
{
    ENSURE_ARG_COUNT(unused, 0);
    
    [centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)startScanWithServices:(id)args
{
    id services = [args objectAtIndex:0];

    ENSURE_TYPE_OR_NIL(services, NSArray);
    
    NSMutableArray<CBUUID*> *uuids = [NSMutableArray array];
    NSMutableDictionary *options = nil;
    
    for (id uuid in services) {
        ENSURE_TYPE(uuid, NSString);
        [uuids addObject:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]];
    }
    
    if ([args count] == 2) {
        id dict = [args objectAtIndex:1];
        
        if ([dict objectAtIndex:@"allowDuplicates"] != nil) {
            [options setObject:[dict objectAtIndex:@"allowDuplicates"]
                        forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
        }
        
        if ([dict objectAtIndex:@"solicitedServiceUUIDs"] != nil) {
            [options setObject:[TiBluetoothUtils UUIDArrayFromStringArray:[dict objectAtIndex:@"solicitedServiceUUIDs"]]
                        forKey:CBCentralManagerScanOptionSolicitedServiceUUIDsKey];
        }
    }
    
    [centralManager scanForPeripheralsWithServices:uuids
                                           options:options];
}

- (void)stopScan:(id)unused
{
    [centralManager stopScan];
}

- (id)isScanning:(id)unused
{
    return NUMBOOL([centralManager isScanning]);
}

- (void)connectPeripheral:(id)args
{
    id peripheral = [args objectAtIndex:0];
    NSMutableDictionary *options = nil;
    
    ENSURE_TYPE(peripheral, TiBluetoothPeripheralProxy);
    
    if ([args count] == 2) {
        ENSURE_TYPE([args objectAtIndex:1], NSDictionary);
        id dict = [args objectAtIndex:1];
        
        if ([dict objectForKey:@"notifyOnConnection"] != nil) {
            [dict setObject:[dict objectForKey:@"notifyOnConnection"] forKey:CBConnectPeripheralOptionNotifyOnConnectionKey];
        }
        
        if ([dict objectForKey:@"notifyOnDisconnection"] != nil) {
            [dict setObject:[dict objectForKey:@"notifyOnDisconnection"] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey];
        }
        
        if ([dict objectForKey:@"notifyOnNotification"] != nil) {
            [dict setObject:[dict objectForKey:@"notifyOnNotification"] forKey:CBConnectPeripheralOptionNotifyOnNotificationKey];
        }
    }
    
    if (![[TiBluetoothPeripheralProvider sharedInstance] hasPeripheral:peripheral]) {
        [[TiBluetoothPeripheralProvider sharedInstance] addPeripheral:peripheral];
    }
    
    [centralManager connectPeripheral:[(TiBluetoothPeripheralProxy *)peripheral peripheral]
                              options:options];
}

- (void)cancelPeripheralConnection:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothPeripheralProxy);
    
    [centralManager cancelPeripheralConnection:[(TiBluetoothPeripheralProxy *)value peripheral]];
}

- (id)state
{
    return NUMINTEGER([centralManager state]);
}

#pragma mark Delegates

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([self _hasListeners:@"didConnectPeripheral"]) {
        [self fireEvent:@"didConnectPeripheral" withObject:@{
            @"peripheral": [self peripheralProxyFromPeripheral:peripheral]
        }];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if ([self _hasListeners:@"didDisconnectPeripheral"]) {
        [self fireEvent:@"didDisconnectPeripheral" withObject:@{
            @"peripheral": [self peripheralProxyFromPeripheral:peripheral]
        }];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([self _hasListeners:@"didDiscoverPeripheral"]) {
        [self fireEvent:@"didDiscoverPeripheral" withObject:@{
            @"peripheral": [self peripheralProxyFromPeripheral:peripheral],
            @"advertisementData": [self dictionaryFromAdvertisementData:advertisementData],
            @"rssi": NUMINT(RSSI)
        }];
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict
{
    if ([self _hasListeners:@"willRestoreState"]) {
        [self fireEvent:@"willRestoreState" withObject:@{
            @"state":NUMINT(central.state)
        }];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if ([self _hasListeners:@"didDisconnectPeripheral"]) {
        [self fireEvent:@"didDisconnectPeripheral" withObject:@{
            @"peripheral": [self peripheralProxyFromPeripheral:peripheral],
            @"error": [error localizedDescription] ?: [NSNull null]
        }];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([self _hasListeners:@"didUpdateState"]) {
        [self fireEvent:@"didUpdateState" withObject:@{
            @"state":NUMINT(central.state)
        }];
    }
}

#pragma mark Utilities

- (TiBluetoothPeripheralProxy *)peripheralProxyFromPeripheral:(CBPeripheral *)peripheral
{
    __block TiBluetoothPeripheralProxy *result = [[TiBluetoothPeripheralProvider sharedInstance] peripheralProxyFromPeripheral:peripheral];
    
    if (!result) {
        NSLog(@"[DEBUG] Could not find cached instance of Ti.Bluetooth.Peripheral proxy. Adding and returning it now.");
        
        result = [[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral];
        [[TiBluetoothPeripheralProvider sharedInstance] addPeripheral:result];
    }
    
    return result;
}

- (NSDictionary *)dictionaryFromAdvertisementData:(NSDictionary *)advertisementData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // Write own handler
    for (id key in advertisementData) {
        if ([[advertisementData objectForKey:key] isKindOfClass:[NSData class]]) {
            [dict setObject:[[TiBlob alloc] _initWithPageContext:[self pageContext] andData:[advertisementData objectForKey:key] mimetype:@"text/plain"] forKey:key];
        } else if ([[advertisementData objectForKey:key] isKindOfClass:[NSNumber class]]) {
            [dict setObject:NUMBOOL([advertisementData objectForKey:key]) forKey:key];
        } else if ([[advertisementData objectForKey:key] isKindOfClass:[NSString class]]) {
            [dict setObject:[TiUtils stringValue:[advertisementData objectForKey:key]] forKey:key];
        } else if ([key isEqualToString:@"kCBAdvDataServiceUUIDs"]) {
            [dict setObject:[TiBluetoothUtils stringArrayFromUUIDArray:[advertisementData objectForKey:key]] forKey:key];
        } else {
            NSLog(@"[DEBUG] Unhandled type for key: %@ - Skipping, please do a PR to handle!", key);
        }
    }
    
    return dict;
}

@end
