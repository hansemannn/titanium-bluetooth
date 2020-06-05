# API's

For both Android & iOS, this API is well-suited to be used when your device acts as the central _(the client)_ and wants to use a peripheral .

The iOS API is provided with extra functionality to let your iOS-device act as a peripheral _(the server)_.

## Overview of API's
* CentralManager
* PeripheralManager **(iOS only)**
* Central **(iOS only)**
* Characteristic
* Descriptor **(iOS only)**
* Peripheral
* Service
* Beacons
* Constants

## `CentralManager`
### Createable
* `createCentralManager`(args)
    * `showPowerAlert` (Boolean) **(iOS only)**
    * `restoreIdentifier` (String) **(iOS only)**
### Methods
* `isScanning()`: Boolean
* `startScan()`
* `startScanWithServices(services)`
    * `services` ([String]): **Required** - Array of Service-UUID
* `stopScan()`
* `connectPeripheral(peripheral, options)`
    * `peripheral` (Peripheral): **Required**
    * `options` (Object): _Optional_
        * `notifyOnConnection` (Boolean)
        * `notifyOnDisconnection` (Boolean)
        * `notifyOnNotification` (Boolean) **(iOS only)**
* `cancelPeripheralConnection(peripheral)`
    * `peripheral` (Peripheral): **Required**
* `retrievePeripheralsWithIdentifiers(identifiers)` **(iOS only)**
    * `identifiers` ([String]): _Optional_
* `retrieveConnectedPeripheralsWithServices(serviceUUIDs)` **(iOS only)**
    * `serviceUUIDs` ([String]): _Optional_
### Properties
* `state` (MANAGER_STATE_*)
* `scanMode` (SCAN_MODE_*)  **(Android only)**
### Events
* `didUpdateState`
* `willRestoreState` **(iOS only)**
* `didDiscoverPeripheral`
* `didConnectPeripheral`
* `didFailToConnectPeripheral`

## `PeripheralManager` (iOS only)
### Createable
createPeripheralManager(args)
showPowerAlert (Boolean)
restoreIdentifier(String)
### Methods
* `isAdvertising`
* `startAdvertising(args)` (Object)
    * `localName` (String): _Optional_
    * `serviceUUIDs` ([String]): String
* `stopAdvertising`
* `setDesiredConnectionLatencyForCentral(latency, central)`
    * `latency` (Number): **Required**
    * `central` (Central): **Required**
* `addService(service)`
    * `service` (Service): **Required**
* `removeService(service)`
    * `service` (Service): **Required**
* `removeAllServices`
* `updateValueForCharacteristicOnSubscribedCentrals(value, characteristic, subscribedCentrals)`
    * `value` (Ti.Blob): **Required**
    * `characteristic` (Characteristic): **Required**
    * `subscribedCentrals` ([String]): **Required** - Array of Central-UUID's
### Properties
* `state` (MANAGER_STATE_*)
### Events
* `didUpdateState`
* `willRestoreState`
* `didStartAdvertising`
* `didAddService`
* `didSubscribeToCharacteristic`
* `didUnsubscribeFromCharacteristic`
* `didReceiveReadRequest`
* `didReceiveWriteRequests`
* `readyToUpdateSubscribers`

## `Central` (iOS only)
### Properties
* `maximumUpdateValueLength` (Number)
* `identifier` (String)

## `Characteristic`
### Createable
* `createCharacteristic` (args) **(iOS only)**
    * `uuid (String)`
    * `properties(CHARACTERISTIC_PROPERTY_*)`
    * `value(Ti.Blob)`
    * `permissions(ATTRIBUTE_PERMISSIONS_*)`
### Properties
* `value` (Ti.Blob)
* `uuid` (String)
* `service` (Service)  **(iOS only)**
* `properties` (CHARACTERISTIC_PROPERTY_*)  **(iOS only)**
* `isNotifying` (Boolean)  **(iOS only)**
* `descriptors` ([Descriptor])  **(iOS only)**

## `Descriptor` (iOS only)
### Properties
* `characteristic` (Characteristic)
* `value` (Mixed)

## `Peripheral`
### Methods
* `readRSSI()` **(iOS only)**
* `discoverServices()`
* `discoverServices(uuids)` **(iOS only)**
    * `uuids` ([String])
* `discoverIncludedServicesForService(includedServices, service)` **(iOS only)**
    * `includedServices` ([Service])
    * `service` (Service)
* `discoverCharacteristicsForService(args)`
    * `characteristics` ([Characteristic]) **(iOS only)**
    * `service` (Service)
* `readValueForCharacteristic(characteristic)` **(iOS only)**
    * `characteristic` (Characteristic)
* `maximumWriteValueLengthForType(type)` **(iOS only)**
    * `type` (CHARACTERISTIC_WRITE_*)
* `writeValueForCharacteristicWithType(value, characteristic, type)`
    * `value` (Ti.Blob)
    * `characteristic` (Characteristic)
    * `type` (CHARACTERISTIC_WRITE_*) 
* `setNotifyValueForCharacteristic(enabled, characteristic)`
    * `enabled` (Boolean)
    * `characteristic` (Characteristic)
* `discoverDescriptorsForCharacteristic` **(iOS only)**
    * `characteristic` (Characteristic)
* `readValueForDescriptor(descriptor)` **(iOS only)**
    * `descriptor` (Descriptor)
* `writeValueForDescriptor(value, descriptor)` **(iOS only)**
    * `value` (Ti.Blob)
    * `descriptor` (Descriptor)

### Properties
* `name`
* `rssi` **(iOS only)**
* `address` **(Android only)**
* `state` **(iOS only)**
* `services`

### Events
* `didDiscoverServices`
* `didDiscoverCharacteristicsForService`
* `didUpdateValueForCharacteristic`
* `didWriteValueForCharacteristic`

## `Service`
### Properties
* `isPrimary` (Boolean) **(iOS only)**
* `peripheral` (Peripheral) **(iOS only)**
* `includedServices` ([String]) **(iOS only)**
* `characteristics` ([Characteristic])
* `uuid` (String)

## Beacons (iOS only)

See the `example/beacons.js` for an advanced beacon example

## `Constants`

### Crossplatform
* `MANAGER_STATE_POWERED_OFF (int)`
* `MANAGER_STATE_POWERED_ON (int)`
* `CHARACTERISTIC_PROPERTY_WRITE_WITH_RESPONSE (int)`
* `CHARACTERISTIC_PROPERTY_WRITE_WITHOUT_RESPONSE (int)`

### Android-only
* `SCAN_MODE_BALANCED (int)`
* `SCAN_MODE_LOW_LATENCY (int)`
* `SCAN_MODE_LOW_POWER (int)`
* `SCAN_MODE_OPPORTUNISTIC (int)`

### iOS-only
* `MANAGER_STATE_UNKNOWN (int)`
* `MANAGER_STATE_UNSUPPORTED (int)`
* `MANAGER_STATE_UNAUTHORIZED (int)`
* `MANAGER_STATE_RESETTING (int)`
* `PERIPHERAL_STATE_DISCONNECTED (int)`
* `PERIPHERAL_STATE_CONNECTING (int)`
* `PERIPHERAL_STATE_CONNECTED (int)`
* `PERIPHERAL_STATE_DISCONNECTING (int)`
* `PERIPHERAL_MANAGER_CONNECTION_LATENCY_LOW (int)`
* `PERIPHERAL_MANAGER_CONNECTION_LATENCY_MEDIUM (int)`
* `PERIPHERAL_MANAGER_CONNECTION_LATENCY_HIGH (int)`
* `ATT_ERROR_SUCCESS (int)`
* `ATT_ERROR_INVALID_HANDLE (int)`
* `ATT_ERROR_READ_NOT_PERMITTED (int)`
* `ATT_ERROR_NOT_PERMITTED (int)`
* `ATT_ERROR_INVALID_PDU (int)`
* `ATT_ERROR_INSUFFICIENT_AUTHENTICATION (int)`
* `ATT_ERROR_NOT_SUPPORTED (int)`
* `ATT_ERROR_INVALID_OFFSET (int)`
* `ATT_ERROR_INSUFFICIENT_AUTHORIZATION (int)`
* `ATT_ERROR_PREPARE_QUEUE_FULL (int)`
* `ATT_ERROR_ATTRIBUTE_NOT_FOUND (int)`
* `ATT_ERROR_ATTRIBUTE_NOT_LONG (int)`
* `ATT_ERROR_INSUFFICIENT_ENCRYPTION_KEY_SITE (int)`
* `ATT_ERROR_INVALID_ATTRIBUTE_VALUE_LENGTH (int)`
* `ATT_ERROR_UNLIKELY_ERROR (int)`
* `ATT_ERROR_INSUFFICIENT_ENCRYPTION (int)`
* `ATT_ERROR_UNSUPPORTED_GROUP_TYPE (int)`
* `ATT_ERROR_INSUFFICIENT_RESOURCES (int)`
* `CHARACTERISTIC_PROPERTY_BROADCAST (int)`
* `CHARACTERISTIC_PROPERTY_READ (int)`
* `CHARACTERISTIC_PROPERTY_WRITE (int)`
* `CHARACTERISTIC_PROPERTY_NOTIFY (int)`
* `CHARACTERISTIC_PROPERTY_INDICATE (int)`
* `CHARACTERISTIC_PROPERTY_AUTHENTICATED_SIGNED_WRITES (int)`
* `CHARACTERISTIC_PROPERTY_EXTENDED_PROPERTIES (int)`
* `CHARACTERISTIC_PROPERTY_NOTIFY_ENCRYPTION_REQUIRED (int)`
* `CHARACTERISTIC_PROPERTY_INDICATE_ENCRYPTION_REQUIRED (int)`
* `CHARACTERISTIC_WRITE_WITH_RESPONSE (int)`
* `CHARACTERISTIC_WRITE_WITHOUT_RESPONSE (int)`
* `ATTRIBUTE_PERMISSIONS_READABLE (int)`
* `ATTRIBUTE_PERMISSIONS_WRITEABLE (int)`
* `ATTRIBUTE_PERMISSIONS_READ_ENCRYPTION_REQUIRED (int)`
* `ATTRIBUTE_PERMISSIONS_WRITE_ENCRYPTION_REQUIRED (int)`
