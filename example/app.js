/** Info.plist entries

<plist>
  <dict>
    	<!-- Use when requiring background execution -->
	<key>UIBackgroundModes</key>
	<array>
        	<!-- Use when acting as a central -->
		<string>bluetooth-central</string>

        	<!-- Use when acting as a peripheral -->
		<string>bluetooth-peripheral</string>
	</array>

    	<!-- Use when acting as a peripheral -->
	<key>NSBluetoothPeripheralUsageDescription</key>
	<string>Can we connect to Bluetooth devices?</string>
  </dict>
</plist>

**/

/**
    Check the documentation to see which api functionalities are available for your platform.
*/

var BLE = require('ti.bluetooth');
var myPeripheral;

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

var btn1 = Ti.UI.createButton({
    title: 'Start scan',
    top: 40
});

var centralManager = BLE.createCentralManager();

if (OS_IOS) {
    var peripheralManager = BLE.createPeripheralManager();
}

btn1.addEventListener('click', function() {
    if (centralManager.isScanning()) {
        alert('Already scanning, please stop scan first!');
        return;
    } else if (centralManager.getState() != BLE.MANAGER_STATE_POWERED_ON) {
        alert('The BLE manager needs to be powered on before. Call initialize().');
        return;
    }

    centralManager.startScan();

    // Optional: Search for specified services
    // centralManager.startScanWithServices(['384DF4C0-8BAE-419D-9A65-2D67942C2DB7']);
});

var btn2 = Ti.UI.createButton({
    title: 'Stop scan',
    top: 100
});

btn2.addEventListener('click', function() {
    if (!centralManager.isScanning()) {
        alert('Not scanning!');
        return;
    }
    centralManager.stopScan();
});

/**
 * Central Manager Events
 */

centralManager.addEventListener('didDiscoverPeripheral', function(e) {
    Ti.API.info('didDiscoverPeripheral');
    Ti.API.info(e);

    if (OS_ANDROID){
        _.each(e.peripheral.uuids, function(item) {
            console.log(e.peripheral.name, ":", e.peripheral.address, '-', item, (item.indexOf("fd6f") > -1) ? " (Exposure Notifications)" : "");
        })
    }

    Ti.API.info('Connect to ' + e.peripheral);
    centralManager.connectPeripheral(e.peripheral, {
        notifyOnConnection: true,
        notifyOnDisconnection: true
    });

    centralManager.stopScan();
});

centralManager.addEventListener('didUpdateState', function(e) {
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

centralManager.addEventListener('didConnectPeripheral', function(e) {
    Ti.API.info('didConnectPeripheral');
    Ti.API.info(e);

    // Now you can add event listener to the found peripheral.
    // Make sure to handle event listeners properly and remove them
    // when you don't need them anymore

    myPeripheral = e.peripheral;

    myPeripheral.addEventListener('didDiscoverServices', function(e) {
        Ti.API.info('didDiscoverServices');
        Ti.API.info(e);
    });

    myPeripheral.addEventListener('didDiscoverCharacteristicsForService', function(e) {
        Ti.API.info('didDiscoverCharacteristicsForService');
        Ti.API.info(e);
    });

    myPeripheral.addEventListener('didUpdateValueForCharacteristic', function(e) {
        Ti.API.info('didUpdateValueForCharacteristic');
        Ti.API.info(e);
    });
});

centralManager.addEventListener('didDisconnectPeripheral', function(e) {
    Ti.API.info('didDisconnectPeripheral');
    Ti.API.info(e);
});

centralManager.addEventListener('willRestoreState', function(e) {
    Ti.API.info('willRestoreState');
    Ti.API.info(e);
});

centralManager.addEventListener('didFailToConnectPeripheral', function(e) {
    Ti.API.info('didFailToConnectPeripheral');
    Ti.API.info(e);
});


/**
 * Peripheral Manager Events
 */

 if (OS_IOS) {
    peripheralManager.addEventListener('didUpdateState', function(e) {
        Ti.API.info('didUpdateState');
        Ti.API.info(e);
    });

    peripheralManager.addEventListener('willRestoreState', function(e) {
       Ti.API.info('willRestoreState');
       Ti.API.info(e);
    });

    peripheralManager.addEventListener('didStartAdvertising', function(e) {
       Ti.API.info('didStartAdvertising');
       Ti.API.info(e);
    });

    peripheralManager.addEventListener('didAddService', function(e) {
       Ti.API.info('didAddService');
       Ti.API.info(e);
    });

    peripheralManager.addEventListener('didSubscribeToCharacteristic', function(e) {
       Ti.API.info('didSubscribeToCharacteristic');
       Ti.API.info(e);
    });

    peripheralManager.addEventListener('didUnsubscribeFromCharacteristic', function(e) {
       Ti.API.info('didUnsubscribeFromCharacteristic');
       Ti.API.info(e);
    });

    peripheralManager.addEventListener('didReceiveReadRequest', function(e) {
       Ti.API.info('didReceiveReadRequest');
       Ti.API.info(e);
    });

    peripheralManager.addEventListener('didReceiveWriteRequests', function(e) {
       Ti.API.info('didReceiveWriteRequests');
       Ti.API.info(e);
    });

    peripheralManager.addEventListener('readyToUpdateSubscribers', function(e) {
       Ti.API.info('readyToUpdateSubscribers');
       Ti.API.info(e);
    });
}

win.add(btn1);
win.add(btn2);
win.open();
