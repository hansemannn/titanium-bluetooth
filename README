Android Titanum BLE Module

iOS version: https://github.com/hansemannn/ti.bluetooth

```javascript
var BLE = require('ti.bluetooth');

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

    //BLE.scanForPeripheralsWithServices(['384DF4C0-8BAE-419D-9A65-2D67942C2DB7']);
    BLE.startScan();
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

// BLE.addEventListener('didConnectPeripheral', function(e) {
//     Ti.API.info('didConnectPeripheral');
//     Ti.API.info(e);
// });

BLE.addEventListener('didDiscoverPeripheral', function(e) {
    Ti.API.info('didDiscoverPeripheral');
    Ti.API.info(JSON.stringify(e));
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

// BLE.addEventListener('didDiscoverServices', function(e) {
//     Ti.API.info('didDiscoverServices');
//     Ti.API.info(e);
// });
// 
// BLE.addEventListener('didDiscoverCharacteristicsForService', function(e) {
//     Ti.API.info('didDiscoverCharacteristicsForService');
//     Ti.API.info(e);
// });
// 
// BLE.addEventListener('didUpdateValueForCharacteristic', function(e) {
//     Ti.API.info('didUpdateValueForCharacteristic');
//     Ti.API.info(e);
// });

win.add(btn1);
win.add(btn2);
win.open();

```
