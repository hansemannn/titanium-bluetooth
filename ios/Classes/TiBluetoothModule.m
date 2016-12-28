/**
 * ti.bluetooth
 *
 * Created by Hans Knoechel
 * Copyright (c) 2016 Hans Knoechel. All rights reserved.
 */

#import <CoreBluetooth/CoreBluetooth.h>

#import "TiBluetoothModule.h"
#import "TiBluetoothUtils.h"
#import "TiBluetoothPeripheralProxy.h"
#import "TiBluetoothCharacteristicProxy.h"
#import "TiBluetoothServiceProxy.h"
#import "TiBluetoothDescriptorProxy.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiBluetoothModule

#pragma mark Internal

// this is generated for your module, please do not change it
- (id)moduleGUID
{
	return @"3c1bc730-d661-401e-8184-84695ad92360";
}

- (NSString *)moduleId
{
	return @"ti.bluetooth";
}

#pragma mark Lifecycle

- (void)startup
{
	[super startup];

	NSLog(@"[DEBUG] %@ loaded",self);
}

- (CBCentralManager *)centralManager
{
    if (!centralManager) {        
        NSLog(@"[ERROR] Trying to use the central manager without calling `initializePeripheralManager`. Using default initializer ...");
        
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    
    return centralManager;
}

- (CBPeripheralManager *)peripheralManager
{
    if (!peripheralManager) {
        NSLog(@"[ERROR] Trying to use the peripheral manager without calling `initializePeripheralManager`. Using default initializer ...");
        
        NSString *bluetoothPermissions = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSBluetoothPeripheralUsageDescription"];
        
        if(!bluetoothPermissions) {
            [self throwException:@"The NSBluetoothPeripheralUsageDescription key is required to interact with Bluetooth on iOS. Please add it to your plist and try it again." subreason:nil location:CODELOCATION];
            return;
        }
        
        peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    
    return peripheralManager;
}

#pragma mark Public APIs

- (void)initializePeripheralManager:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
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
    
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:options.count > 0 ? options : nil];
}

- (void)initializeCentralManager:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    NSNumber *showPowerAlert;
    NSString *restoreIdentifier;
    
    ENSURE_ARG_OR_NIL_FOR_KEY(showPowerAlert, args, @"showPowerAlert", NSNumber);
    ENSURE_ARG_OR_NIL_FOR_KEY(restoreIdentifier, args, @"restoreIdentifier", NSString);
    
    if (showPowerAlert) {
        [options setObject:showPowerAlert forKey:CBPeripheralManagerOptionShowPowerAlertKey];
    }
    
    if (restoreIdentifier) {
        [options setObject:restoreIdentifier forKey:CBPeripheralManagerOptionRestoreIdentifierKey];
    }
    
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:options];
}

- (TiBluetoothCharacteristicProxy *)createCharacteristic:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id uuid = [args objectForKey:@"uuid"];
    id properties = [args objectForKey:@"properties"];
    id value = [args objectForKey:@"value"];
    id permissions = [args objectForKey:@"permissions"];
    
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]
                                                                                 properties:[TiUtils intValue:properties]
                                                                                      value:[(TiBlob *)value data]
                                                                                permissions:[TiUtils intValue:permissions]];
    
    return [[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext]
                                                      andCharacteristic:characteristic];
}

- (TiBluetoothServiceProxy *)createService:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id uuid = [args objectForKey:@"uuid"];
    id primary = [args objectForKey:@"primary"];
    id characteristics = [args objectForKey:@"characteristics"];
    id includedServices = [args objectForKey:@"includedServices"];
    
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]
                                                               primary:[TiUtils boolValue:primary]];
    
    if (characteristics) {
        NSMutableArray *result = [NSMutableArray array];
        
        for (id characteristic in characteristics) {
            ENSURE_TYPE(characteristic, TiBluetoothCharacteristicProxy);
            [result addObject:[(TiBluetoothCharacteristicProxy *)characteristic characteristic]];
        }
        
        [service setCharacteristics:result];
    }
    
    if (includedServices) {
        NSMutableArray *result = [NSMutableArray array];
        
        for (id includedService in includedServices) {
            ENSURE_TYPE(includedService, TiBluetoothServiceProxy);
            [result addObject:[(TiBluetoothServiceProxy *)includedService service]];
        }
        
        [service setIncludedServices:result];
    }
    
    return [[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext]
                                                      andService:service];
}

- (TiBluetoothDescriptorProxy *)createDescriptor:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id uuid = [args objectForKey:@"uuid"];
    id value = [args objectForKey:@"value"];
    
    CBMutableDescriptor *descriptor = [[CBMutableDescriptor alloc] initWithType:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]
                                                                          value:[(TiBlob *)value data]];
    
    return [[TiBluetoothDescriptorProxy alloc] _initWithPageContext:[self pageContext]
                                                      andDescriptor:descriptor];
}

- (void)initialize:(id)unused
{
    [self centralManager];
}

- (void)startScan:(id)unused
{
    ENSURE_ARG_COUNT(unused, 0);
    
    [[self centralManager] scanForPeripheralsWithServices:nil options:nil];
}

- (void)startScanWithServices:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSArray);
    
    NSMutableArray<CBUUID*> *uuids = [NSMutableArray array];
    
    for (id uuid in args) {
        ENSURE_TYPE(uuid, NSString);
        [uuids addObject:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]];
    }
    
    [[self centralManager] scanForPeripheralsWithServices:uuids options:nil];
}

- (void)stopScan:(id)unused
{
    [[self centralManager] stopScan];
}

- (id)isScanning:(id)unused
{
    return NUMBOOL([[self centralManager] isScanning]);
}

- (void)connectPeripheral:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothPeripheralProxy);
    
    [[self centralManager] connectPeripheral:[(TiBluetoothPeripheralProxy *)value peripheral] options:nil];
}

- (void)cancelPeripheralConnection:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothPeripheralProxy);
    
    [[self centralManager] cancelPeripheralConnection:[(TiBluetoothPeripheralProxy *)value peripheral]];
}

- (id)centralManagerState
{
    return NUMINTEGER([[self centralManager] state]);
}

- (id)peripheralManagerState
{
    return NUMINTEGER([[self peripheralManager] state]);
}

#pragma mark - Delegates

#pragma mark Central Manager Delegates

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([self _hasListeners:@"centralManager:didConnectPeripheral"]) {
        [self fireEvent:@"centralManager:didConnectPeripheral" withObject:@{
            @"peripheral":[[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral]
        }];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([self _hasListeners:@"centralManager:didDiscoverPeripheral"]) {
        [self fireEvent:@"centralManager:didDiscoverPeripheral" withObject:@{
            @"peripheral":[[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral],
            @"advertisementData": [self dictionaryFromAdvertisementData:advertisementData],
            @"rssi": NUMINT(RSSI)
        }];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([self _hasListeners:@"centralManager:didUpdateState"]) {
        [self fireEvent:@"centralManager:didUpdateState" withObject:@{
            @"state":NUMINT(central.state)
        }];
    }
}

#pragma mark Peripheral Manager Delegates

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if ([self _hasListeners:@"peripheralManager:didUpdateState"]) {
        [self fireEvent:@"peripheralManager:didUpdateState" withObject:@{
            @"state":NUMINT(peripheral.state)
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *, id> *)dict
{
    if ([self _hasListeners:@"peripheralManager:willRestoreState"]) {
        [self fireEvent:@"peripheralManager:willRestoreState" withObject:@{
            @"state":NUMINT(peripheral.state)
        }];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error
{
    if ([self _hasListeners:@"peripheralManager:didStartAdvertising"]) {
        [self fireEvent:@"peripheralManager:didStartAdvertising" withObject:@{
            @"success": NUMBOOL(error == nil),
            @"error": [error localizedDescription] ?: [NSNull null]
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(nullable NSError *)error
{
    if ([self _hasListeners:@"peripheralManager:didAddService"]) {
        [self fireEvent:@"peripheralManager:didAddService" withObject:@{
            @"service":[[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:service],
            @"error": [error localizedDescription] ?: [NSNull null]
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    if ([self _hasListeners:@"peripheralManager:didSubscribeToCharacteristic"]) {
        [self fireEvent:@"peripheralManager:didSubscribeToCharacteristic" withObject:@{
            @"characteristic":[[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:characteristic]
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    if ([self _hasListeners:@"peripheralManager:didUnsubscribeFromCharacteristic"]) {
        [self fireEvent:@"peripheralManager:didUnsubscribeFromCharacteristic" withObject:@{
            @"characteristic":[[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:characteristic]
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request;
{
    if ([self _hasListeners:@"peripheralManager:didReceiveReadRequest"]) {
        [self fireEvent:@"peripheralManager:didReceiveReadRequest" withObject:@{
            @"characteristic":[[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:request.characteristic],
            @"offset": NUMUINTEGER(request.offset)
        }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    if ([self _hasListeners:@"peripheralManager:didReceiveWriteRequests"]) {
        [self fireEvent:@"peripheralManager:didReceiveWriteRequests" withObject:@{
            @"characteristics":[self arrayFromReadWriteRequests:requests]
        }];
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    if ([self _hasListeners:@"peripheralManager:readyToUpdateSubscribers"]) {
        [self fireEvent:@"peripheralManager:readyToUpdateSubscribers" withObject:nil];
    }
}

#pragma mark Peripheral Delegates

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if ([self _hasListeners:@"peripheral:didDiscoverServices"]) {
        [self fireEvent:@"didDiscoverServices" withObject:@{
            @"peripheral": [[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral],
            @"error": [error localizedDescription] ?: @""
        }];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([self _hasListeners:@"peripheral:didDiscoverCharacteristicsForService"]) {
        [self fireEvent:@"peripheral:didDiscoverCharacteristicsForService" withObject:@{
            @"peripheral": [[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral],
            @"service": [[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:service],
            @"error": [error localizedDescription] ?: @""
        }];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([self _hasListeners:@"peripheral:didUpdateValueForCharacteristic"]) {
        [self fireEvent:@"peripheral:didUpdateValueForCharacteristic" withObject:@{
            @"characteristic": [[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:characteristic],
            @"error": [error localizedDescription] ?: @""
        }];
    }
}

#pragma mark Utilities

- (NSArray *)arrayFromServices:(NSArray<CBService *> *)services
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBService *service in services) {
        [result addObject:[[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:service]];
    }
    
    return result;
}

- (NSArray *)arrayFromCharacteristics:(NSArray<CBCharacteristic *> *)characteristics
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBCharacteristic *characteristic in characteristics) {
        [result addObject:[[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:characteristic]];
    }
    
    return result;
}

- (NSArray*)arrayFromReadWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBATTRequest *request in requests) {
        [result addObject:[[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:request.characteristic]];
    }
    
    return result;
}

- (NSArray *)arrayFromDescriptors:(NSArray<CBDescriptor *> *)descriptors
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBDescriptor *descriptor in descriptors) {
        [result addObject:[[TiBluetoothDescriptorProxy alloc] _initWithPageContext:[self pageContext] andDescriptor:descriptor]];
    }
    
    return result;
}

- (NSDictionary *)dictionaryFromAdvertisementData:(NSDictionary *)advertisementData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // Write own handler
    for (id key in advertisementData) {
        if ([[advertisementData objectForKey:key] isKindOfClass:[NSData class]]) {
            [dict setObject:[[TiBlob alloc] initWithData:[advertisementData objectForKey:key] mimetype:@"text/plain"] forKey:key];
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

#pragma mark Constants

MAKE_SYSTEM_PROP(PERIPHERAL_STATE_DISCONNECTED, CBPeripheralStateDisconnected);
MAKE_SYSTEM_PROP(PERIPHERAL_STATE_CONNECTING, CBPeripheralStateDisconnecting);
MAKE_SYSTEM_PROP(PERIPHERAL_STATE_CONNECTED, CBPeripheralStateConnected);
MAKE_SYSTEM_PROP(PERIPHERAL_STATE_DISCONNECTING, CBPeripheralStateDisconnecting);

MAKE_SYSTEM_PROP(MANAGER_STATE_UNKNOWN, CBManagerStateUnknown);
MAKE_SYSTEM_PROP(MANAGER_STATE_RESETTING, CBManagerStateResetting);
MAKE_SYSTEM_PROP(MANAGER_STATE_UNSUPPORTED, CBManagerStateUnsupported);
MAKE_SYSTEM_PROP(MANAGER_STATE_UNAUTHORIZED, CBManagerStateUnauthorized);
MAKE_SYSTEM_PROP(MANAGER_STATE_POWERED_OFF, CBManagerStatePoweredOff);
MAKE_SYSTEM_PROP(MANAGER_STATE_POWERED_ON, CBManagerStatePoweredOn);

@end
