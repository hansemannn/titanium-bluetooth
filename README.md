# Ti.Bluetooth [![Build Status](https://travis-ci.org/hansemannn/ti.bluetooth.svg?branch=master)](https://travis-ci.org/hansemannn/ti.bluetooth)

Summary
---------------
Ti.Bluetooth is an open source project to support the Bluetooth in Titanium Mobile.

Requirements
---------------
- Titanium Mobile SDK 6.0.0.GA or later
- iOS 7.1 / Android 4.0.0 or later
- Xcode 8.0 or later

Download + Setup
---------------

### Download
* [Stable release](https://github.com/hansemannn/ti.bluetooth/releases)
* Install from gitTio    <a href="http://gitt.io/component/ti.bluetooth" target="_blank"><img src="http://gitt.io/badge@2x.png" width="120" height="18" alt="Available on gitTio" /></a>

### Setup
Unpack the module and place it inside the `modules/` folder of your project.
Edit the modules section of your `tiapp.xml` file to include this module:
```xml
<modules>
    <module>ti.bluetooth</module>
</modules>
```
Add the following to your plist (only neccessary for iOS):
```xml
<plist>
    <dict>
        <key>UIBackgroundModes</key>
        <array>
            <string>bluetooth-central</string>
            <string>bluetooth-peripheral</string>
        </array>
        <key>NSBluetoothPeripheralUsageDescription</key>
        <string>Can we connect to Bluetooth devices?</string>
    </dict>
</plist>
```

Features
--------------------------------
- [x] Create descriptors, services and descriptors
- [x] Start / Stop peripheral scanning
- [x] Receive state events

#### Documentation 

API documentation can be found at [documentation/index.md](documentation/index.md)

#### Example
```js
var BLE = require('ti.bluetooth');
var isAndroid = (Ti.Platform.osname == 'android');

// Initialize the BLE Central Manager
BLE.initialize();

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

var btn1 = Ti.UI.createButton({
    title: 'Start scan',
    top: 40
});

btn1.addEventListener('click', function() {
    if (BLE.isScanning()) {
        alert('Already scanning, please stop scan first!');
        return;
    } else if (BLE.getState() != BLE.MANAGER_STATE_POWERED_ON) {
        alert('The BLE manager needs to be powered on before. Call initialize().');
        return;
    }

    BLE.startScan();

    // Optional: Search for specified services
    // BLE.startScanWithServices(['384DF4C0-8BAE-419D-9A65-2D67942C2DB7']);
});

var btn2 = Ti.UI.createButton({
    title: 'Stop scan',
    top: 100
});

btn2.addEventListener('click', function() {
    if (!BLE.isScanning()) {
        alert('Not scanning!');
        return;
    }
    BLE.stopScan();
});

BLE.addEventListener('didDiscoverPeripheral', function(e) {
    Ti.API.info('didDiscoverPeripheral');
    Ti.API.info(e);
});

BLE.addEventListener('didUpdateState', function(e) {
    Ti.API.info('didUpdateState');
    
    switch (e.state) {
        case BLE.MANAGER_STATE_RESETTING: 
            Ti.API.info('Resetting');
        break;

        case BLE.MANAGER_STATE_UNSUPPORTED: 
            Ti.API.info('Unsupported');
        break;

        case BLE.MANAGER_STATE_UNAUTHORIZED: 
            Ti.API.info('Unauthorized');
        break;
        
        case BLE.MANAGER_STATE_POWERED_OFF: 
            Ti.API.info('Powered Off');
        break;
        
        case BLE.MANAGER_STATE_POWERED_ON: 
            Ti.API.info('Powered On');
        break;
        
        case BLE.MANAGER_STATE_UNKNOWN: 
        default: 
            Ti.API.info('Unknown');
        break;
    }
});

// iOS only
BLE.addEventListener('didConnectPeripheral', function(e) {
    Ti.API.info('didConnectPeripheral');
    Ti.API.info(e);
});

// iOS only
BLE.addEventListener('didDiscoverServices', function(e) {
    Ti.API.info('didDiscoverServices');
    Ti.API.info(e);
});

// iOS only
BLE.addEventListener('didDiscoverCharacteristicsForService', function(e) {
    Ti.API.info('didDiscoverCharacteristicsForService');
    Ti.API.info(e);
});

// iOS only
BLE.addEventListener('didUpdateValueForCharacteristic', function(e) {
    Ti.API.info('didUpdateValueForCharacteristic');
    Ti.API.info(e);
});

win.add(btn1);
win.add(btn2);
win.open();
```

Authors
---------------
- [x] Hans Knoechel ([@hansemannnn](https://twitter.com/hansemannnn) / [Web](http://hans-knoechel.de))
- [x] Michael Gangolf ([@MichaelGangolf](https://twitter.com/MichaelGangolf) / [Web](http://migaweb.de))

License
---------------
Apache 2.0

Contributing
---------------
Code contributions are greatly appreciated, please submit a new [pull request](https://github.com/hansemannn/ti.bluetooth/pull/new/master)!
