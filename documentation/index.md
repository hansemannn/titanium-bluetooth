# API documentation

## Properties



* `MANAGER_STATE_UNKNOWN` _(int)_
* `MANAGER_STATE_UNSUPPORTED` _(int)_
* `MANAGER_STATE_UNAUTHORIZED` _(int)_
* `MANAGER_STATE_POWERED_OFF` _(int)_
* `MANAGER_STATE_POWERED_ON` _(int)_
* `MANAGER_STATE_RESETTING` _(int)_
* `SCAN_MODE_BALANCED` _(int)_ - (Android only)
* `SCAN_MODE_LOW_LATENCY` _(int)_ - (Android only)
* `SCAN_MODE_LOW_POWER` _(int)_ - (Android only)
* `SCAN_MODE_OPPORTUNISTIC` _(int)_ - (Android only)

## Methods
* `isScanning()`
* `startScan()`
* `getScanMode()`
* `setScanMode()`
* `initialize()`
* `stopScan()`
* `startScanWithServices([Array])`

## Events
* `didUpdateState`
* `didDiscoverPeripheral`
* `didConnectPeripheral` - (iOS only)
* `didDiscoverServices` - (iOS only)
* `didDiscoverCharacteristicsForService` - (iOS only)
* `didUpdateValueForCharacteristic`  - (iOS only)
