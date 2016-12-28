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

#pragma mark Public APIs

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

MAKE_SYSTEM_PROP(PERIPHERAL_MANAGER_CONNECTION_LATENCY_LOW, CBPeripheralManagerConnectionLatencyLow);
MAKE_SYSTEM_PROP(PERIPHERAL_MANAGER_CONNECTION_LATENCY_MEDIUM, CBPeripheralManagerConnectionLatencyMedium);
MAKE_SYSTEM_PROP(PERIPHERAL_MANAGER_CONNECTION_LATENCY_HIGH, CBPeripheralManagerConnectionLatencyHigh);

MAKE_SYSTEM_PROP(ATT_ERROR_SUCCESS, CBATTErrorSuccess);
MAKE_SYSTEM_PROP(ATT_ERROR_INVALID_HANDLE, CBATTErrorInvalidHandle);
MAKE_SYSTEM_PROP(ATT_ERROR_READ_NOT_PERMITTED, CBATTErrorReadNotPermitted);
MAKE_SYSTEM_PROP(ATT_ERROR_NOT_PERMITTED, CBATTErrorWriteNotPermitted);
MAKE_SYSTEM_PROP(ATT_ERROR_INVALID_PDU, CBATTErrorInvalidPdu);
MAKE_SYSTEM_PROP(ATT_ERROR_INSUFFICIENT_AUTHENTICATION, CBATTErrorInsufficientAuthentication);
MAKE_SYSTEM_PROP(ATT_ERROR_NOT_SUPPORTED, CBATTErrorRequestNotSupported);
MAKE_SYSTEM_PROP(ATT_ERROR_INVALID_OFFSET, CBATTErrorInvalidOffset);
MAKE_SYSTEM_PROP(ATT_ERROR_INSUFFICIENT_AUTHORIZATION, CBATTErrorInsufficientAuthorization);
MAKE_SYSTEM_PROP(ATT_ERROR_PREPARE_QUEUE_FULL, CBATTErrorPrepareQueueFull);
MAKE_SYSTEM_PROP(ATT_ERROR_ATTRIBUTE_NOT_FOUND, CBATTErrorAttributeNotFound);
MAKE_SYSTEM_PROP(ATT_ERROR_ATTRBITE_NOT_LONG, CBATTErrorAttributeNotLong);
MAKE_SYSTEM_PROP(ATT_ERROR_INSUFFICIENT_ENCRYPTION_KEY_SITE, CBATTErrorInsufficientEncryptionKeySize);
MAKE_SYSTEM_PROP(ATT_ERROR_INVALID_ATTRIBUTE_VALUE_LENGTH, CBATTErrorInvalidAttributeValueLength);
MAKE_SYSTEM_PROP(ATT_ERROR_UNLIKELY_ERROR, CBATTErrorUnlikelyError);
MAKE_SYSTEM_PROP(ATT_ERROR_INSUFFICIENT_ENCRYPTION, CBATTErrorInsufficientEncryption);
MAKE_SYSTEM_PROP(ATT_ERROR_UNSUPPORTED_GROUP_TYPE, CBATTErrorUnsupportedGroupType);
MAKE_SYSTEM_PROP(ATT_ERROR_INSUFFICIENT_RESOURCES, CBATTErrorInsufficientResources);

@end
