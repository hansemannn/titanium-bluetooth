# Ti.Bluetooth 
[![Build Status](https://travis-ci.org/hansemannn/ti.bluetooth.svg?branch=master)](https://travis-ci.org/hansemannn/ti.bluetooth) [![License](http://hans-knoechel.de/shields/shield-license.svg?v=1)](./LICENSE) [![Support](http://hans-knoechel.de/shields/shield-slack.svg?v=1)](http://tislack.org)

Summary
---------------
Ti.Bluetooth is an open source project to support Bluetooth / BLE in Appcelerator Titanium.

Requirements
---------------
- Titanium Mobile SDK 6.0.0.GA or later
- iOS 7.1 / Android 4.0.0 or later
- Xcode 8.0 or later

Download + Setup
---------------

### Download
* [Stable release](https://github.com/hansemannn/ti.bluetooth/releases)
* Install from gitTio [![gitTio](http://hans-knoechel.de/shields/shield-gittio.svg)](http://gitt.io/component/ti.bluetooth)

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
- [x] Create central managers, peripheral managers, descriptors, characteristics, centrals, services and requests
- [x] Start / Stop peripheral scanning
- [x] Send data between devices
- [x] Receive state events

#### Documentation 

An API documentation can be found at [documentation/index.md](documentation/index.md).

#### Example
> Please check [ios/example/app.js](ios/example/app.js) and [android/example/app.js](android/example/app.js) for platform-specific examples.

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
