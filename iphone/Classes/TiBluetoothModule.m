/**
 * ti.bluetooth
 *
 * Created by Hans Knoechel
 * Copyright (c) 2016 Hans Knoechel. All rights reserved.
 */

#import "TiBluetoothModule.h"
#import "TiBluetoothPeripheralProxy.h"
#import "TiBluetoothCharacteristicProxy.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiBluetoothModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"3c1bc730-d661-401e-8184-84695ad92360";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.bluetooth";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

	NSLog(@"[DEBUG] %@ loaded",self);
}

- (CBCentralManager*)centralManager
{
    if (!centralManager) {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return centralManager;
}

#pragma mark Public APIs

-(void)scanForPeripheralsWithServices:(id)args
{
    ENSURE_SINGLE_ARG(args, NSArray);
    
    for (id uuid in args) {
        ENSURE_TYPE(uuid, NSString);
    }
    
    [[self centralManager] scanForPeripheralsWithServices:(NSArray<CBUUID*>*)args
                                                  options:nil];
}

-(void)stopScan:(id)unused
{
    [[self centralManager] stopScan];
}

-(id)isScanning:(id)unused
{
    return NUMBOOL([[self centralManager] isScanning]);
}

-(void)connectPeripheral:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothPeripheralProxy);
    
    [[self centralManager] connectPeripheral:[(TiBluetoothPeripheralProxy*)value peripheral] options:nil];
}

-(void)cancelPeripheralConnection:(id)value
{
    ENSURE_SINGLE_ARG(value, TiBluetoothPeripheralProxy);
    
    [[self centralManager] cancelPeripheralConnection:[(TiBluetoothPeripheralProxy*)value peripheral]];
}

#pragma mark - Delegates

#pragma mark Central Manager Delegates

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([self _hasListeners:@"didConnectPeripheral"]) {
        [self fireEvent:@"didConnectPeripheral" withObject:@{@"peripheral":[TiBluetoothModule dictionaryFromPeripheral:peripheral]}];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([self _hasListeners:@"didDiscoverPeripheral"]) {
        [self fireEvent:@"didDiscoverPeripheral" withObject:@{
                                                              @"peripheral":[TiBluetoothModule dictionaryFromPeripheral:peripheral],
                                                              @"advertisementData": advertisementData,
                                                              @"rssi": NUMINT(RSSI)
                                                              }];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([self _hasListeners:@"didUpdateState"]) {
        [self fireEvent:@"didUpdateState" withObject:@{@"state":NUMINT(central.state)}];
    }
}

#pragma mark Peripheral Delegates

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if ([self _hasListeners:@"didDiscoverServices"]) {
        [self fireEvent:@"didDiscoverServices" withObject:@{
                                                            @"peripheral": [TiBluetoothModule dictionaryFromPeripheral:peripheral],
                                                            @"error": [error localizedDescription] ?: @""
                                                            }];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([self _hasListeners:@"didDiscoverCharacteristicsForService"]) {
        [self fireEvent:@"didDiscoverCharacteristicsForService" withObject:@{
                                                                             @"peripheral": [TiBluetoothModule dictionaryFromPeripheral:peripheral],
                                                                             @"service": [TiBluetoothModule dictionaryFromService:service],
                                                                             @"error": [error localizedDescription] ?: @""
                                                                             }];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([self _hasListeners:@"didUpdateValueForCharacteristic"]) {
        [self fireEvent:@"didUpdateValueForCharacteristic" withObject:@{
                                                            @"characteristic": [TiBluetoothModule dictionaryFromCharacteristic:characteristic],
                                                            @"error": [error localizedDescription] ?: @""
                                                            }];
    }
}

#pragma mark Utilities

+(NSArray*)arrayFromServices:(NSArray<CBService*>*)services
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBService *service in services) {
        [result addObject:[TiBluetoothModule dictionaryFromService:service]];
    }
    
    return result;
}

+(NSArray*)arrayFromCharacteristics:(NSArray<CBCharacteristic*>*)characteristics
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBCharacteristic *characteristic in characteristics) {
        [result addObject:[TiBluetoothModule dictionaryFromCharacteristic:characteristic]];
    }
    
    return result;
}

+(NSArray*)arrayFromDescriptors:(NSArray<CBDescriptor*>*)descriptors
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CBDescriptor *descriptor in descriptors) {
        [result addObject:[TiBluetoothModule dictionaryFromDescriptor:descriptor]];
    }
    
    return result;
}

+(NSDictionary*)dictionaryFromPeripheral:(CBPeripheral*)peripheral
{
    return @{
             @"name": peripheral.name,
             @"rssi": NUMINT(peripheral.RSSI),
             @"state": NUMINT(peripheral.state),
             @"services": [TiBluetoothModule arrayFromServices:peripheral.services]
             };
}

+(NSDictionary*)dictionaryFromService:(CBService*)service
{
    return @{
             @"isPrimary": NUMBOOL(service.isPrimary),
             @"peripheral": [TiBluetoothModule dictionaryFromPeripheral:service.peripheral],
             @"includedServices": [TiBluetoothModule arrayFromServices:service.includedServices],
             @"characteristics": [TiBluetoothModule arrayFromCharacteristics:service.characteristics]
             };
}

+(NSDictionary*)dictionaryFromCharacteristic:(CBCharacteristic*)characteristic
{
    return @{
             @"service": [TiBluetoothModule dictionaryFromService:characteristic.service],
             @"properties": NUMUINTEGER(characteristic.properties),
             @"isBroadcasted": NUMBOOL(characteristic.isBroadcasted),
             @"isNotifying": NUMBOOL(characteristic.isNotifying),
             @"descriptors": [TiBluetoothModule arrayFromDescriptors:characteristic.descriptors],
             @"value": [[TiBlob alloc] initWithData:characteristic.value mimetype:@"text/plain"]
             };
}

+(NSDictionary*)dictionaryFromDescriptor:(CBDescriptor*)descriptor
{
    return @{
             @"characteristic": [TiBluetoothModule dictionaryFromCharacteristic:descriptor.characteristic],
             @"value": descriptor.value
             };
}

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
