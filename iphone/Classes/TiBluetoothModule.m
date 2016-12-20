/**
 * ti.bluetooth
 *
 * Created by Hans Knoechel
 * Copyright (c) 2016 Hans Knoechel. All rights reserved.
 */

#import "TiBluetoothModule.h"
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

- (NSString*)moduleId
{
	return @"ti.bluetooth";
}

#pragma mark Lifecycle

- (void)startup
{
	[super startup];

	NSLog(@"[DEBUG] %@ loaded",self);
}

- (CBCentralManager*)centralManager
{
    if (!centralManager) {
        NSString *bluetoothPermissions = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSBluetoothPeripheralUsageDescription"];
        
        if(!bluetoothPermissions) {
            [self throwException:@"The NSBluetoothPeripheralUsageDescription key is required to interact with Bluetooth on iOS. Please add it to your plist and try it again." subreason:nil location:CODELOCATION];
            return;
        }
        
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return centralManager;
}

#pragma mark Public APIs

- (TiBluetoothCharacteristicProxy*)createCharacteristic:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id uuid = [args objectForKey:@"uuid"];
    id properties = [args objectForKey:@"properties"];
    id value = [args objectForKey:@"value"];
    id permissions = [args objectForKey:@"permissions"];
    
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]
                                                                                 properties:[TiUtils intValue:properties]
                                                                                      value:[(TiBlob*)value data]
                                                                                permissions:[TiUtils intValue:permissions]];
    
    return [[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext]
                                                      andCharacteristic:characteristic];
}

- (TiBluetoothServiceProxy*)createService:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id uuid = [args objectForKey:@"uuid"];
    id primary = [args objectForKey:@"primary"];
    
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]
                                                               primary:[TiUtils boolValue:primary]];
    
    return [[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext]
                                                      andService:service];
}

- (TiBluetoothDescriptorProxy*)createDescriptor:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id uuid = [args objectForKey:@"uuid"];
    id value = [args objectForKey:@"value"];
    
    CBMutableDescriptor *descriptor = [[CBMutableDescriptor alloc] initWithType:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]
                                                                          value:[(TiBlob*)value data]];
    
    return [[TiBluetoothDescriptorProxy alloc] _initWithPageContext:[self pageContext]
                                                      andDescriptor:descriptor];
}

- (void)scanForPeripheralsWithServices:(id)args
{
    ENSURE_SINGLE_ARG(args, NSArray);
    
    NSMutableArray<CBUUID*> *uuids = [NSMutableArray array];

    for (id uuid in args) {
        ENSURE_TYPE(uuid, NSString);
        [uuids addObject:[CBUUID UUIDWithString:[TiUtils stringValue:uuid]]];
    }
    
    [[self centralManager] scanForPeripheralsWithServices:uuids
                                                  options:nil];
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
    
    [[self centralManager] connectPeripheral:[(TiBluetoothPeripheralProxy*)value peripheral] options:nil];
}

- (void)cancelPeripheralConnection:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothPeripheralProxy);
    
    [[self centralManager] cancelPeripheralConnection:[(TiBluetoothPeripheralProxy*)value peripheral]];
}

#pragma mark - Delegates

#pragma mark Central Manager Delegates

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([self _hasListeners:@"didConnectPeripheral"]) {
        [self fireEvent:@"didConnectPeripheral" withObject:@{
            @"peripheral":[[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral]
        }];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([self _hasListeners:@"didDiscoverPeripheral"]) {
        [self fireEvent:@"didDiscoverPeripheral" withObject:@{
            @"peripheral":[[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral],
            @"advertisementData": advertisementData,
            @"rssi": NUMINT(RSSI)
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

#pragma mark Peripheral Delegates

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if ([self _hasListeners:@"didDiscoverServices"]) {
        [self fireEvent:@"didDiscoverServices" withObject:@{
            @"peripheral": [[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral],
            @"error": [error localizedDescription] ?: @""
        }];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([self _hasListeners:@"didDiscoverCharacteristicsForService"]) {
        [self fireEvent:@"didDiscoverCharacteristicsForService" withObject:@{
            @"peripheral": [[TiBluetoothPeripheralProxy alloc] _initWithPageContext:[self pageContext] andPeripheral:peripheral],
            @"service": [[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:service],
            @"error": [error localizedDescription] ?: @""
        }];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([self _hasListeners:@"didUpdateValueForCharacteristic"]) {
        [self fireEvent:@"didUpdateValueForCharacteristic" withObject:@{
            @"characteristic": [[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:characteristic],
            @"error": [error localizedDescription] ?: @""
        }];
    }
}

#pragma mark Utilities

- (NSArray*)arrayFromServices:(NSArray<CBService*>*)services
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBService *service in services) {
        [result addObject:[[TiBluetoothServiceProxy alloc] _initWithPageContext:[self pageContext] andService:service]];
    }
    
    return result;
}

- (NSArray*)arrayFromCharacteristics:(NSArray<CBCharacteristic*>*)characteristics
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBCharacteristic *characteristic in characteristics) {
        [result addObject:[[TiBluetoothCharacteristicProxy alloc] _initWithPageContext:[self pageContext] andCharacteristic:characteristic]];
    }
    
    return result;
}

- (NSArray*)arrayFromDescriptors:(NSArray<CBDescriptor*>*)descriptors
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBDescriptor *descriptor in descriptors) {
        [result addObject:[[TiBluetoothDescriptorProxy alloc] _initWithPageContext:[self pageContext] andDescriptor:descriptor]];
    }
    
    return result;
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
