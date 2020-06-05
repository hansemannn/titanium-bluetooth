/** Required Info.plist entries

<plist>
  <dict>
	<key>NSBluetoothAlwaysUsageDescription</key>
	<string>Can we connect to Bluetooth devices?</string>
	<key>NSBluetoothPeripheralUsageDescription</key>
	<string>Can we connect to Bluetooth devices?</string>
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>Can we access your location?</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>Can we always access your location?</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Can we access your location?</string>
	<key>UIBackgroundModes</key>
	<array>
		<string>bluetooth-central</string>
		<string>bluetooth-peripheral</string>
		<string>location</string>
		<string>processing</string>
	</array>
  </dict>
</plist>

**/

var BLE = require('ti.bluetooth');

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

win.addEventListener('open', registerForPush);

var beaconManager = BLE.createBeaconManager();
var rangedBeacons = [];

beaconManager.addEventListener('applicationOpenedFromLocation', checkPermissions);

beaconManager.addEventListener('didRangeBeacons', function (event) {
  for (const beacon of event.beacons) {
    if (!rangedBeacons.includes(beacon.uuid)) {
      rangedBeacons.push(beacon.uuid);
      sendPush('Found beacon with UUID = ' + beacon.uuid);
    }
  }
  win.backgroundColor = 'red';
});

beaconManager.addEventListener('didEnterRegion', function (event) {
  console.warn('didEnterRegion!');
  console.warn(event);

  sendPush('Did enter region!');
});

beaconManager.addEventListener('didExitRegion', function (event) {
  console.warn('didExitRegion!');
  console.warn(event);

  sendPush('Did exit region!');
});

var btn = Ti.UI.createButton({ title: 'Start ranging!' });
btn.addEventListener('click', checkPermissions);

win.add(btn);
win.open();

function checkPermissions() {
  beaconManager.requestAlwaysAuthorization(function (event) {
    if (event.success) {
      startRanging();
    } else {
      alert('NO PERMISSIONS')
    }
  })
}

function startRanging() {
  if (!beaconManager.isBeaconRangingAvailable) {
    alert('Cannot use beacon ranging on this device!');
  }

  beaconManager.startRangingBeaconsInRegion({
    uuid: '63ff97ce-0607-4903-af64-1a7f94b59918',
    major: 1,
    minor: 2,
    identifier: 'test'
  });
}

function sendPush(title) {
  Ti.App.iOS.scheduleLocalNotification({
    alertBody: title,
    badge: 0,
    date: new Date(new Date().getTime() + 3000)
  });
}

function registerForPush() {
  Ti.App.iOS.addEventListener('usernotificationsettings', function eventUserNotificationSettings() {
    // Remove the event again to prevent duplicate calls through the Firebase API
    Ti.App.iOS.removeEventListener('usernotificationsettings', eventUserNotificationSettings);

    // Register for push notifications (Ti)
    Ti.Network.registerForPushNotifications({
      success: () => {},
      error: () => {},
      callback: () => {}
    });
  });

  // Register for the notification settings event
  Ti.App.iOS.registerUserNotificationSettings({
    types: [
      Ti.App.iOS.USER_NOTIFICATION_TYPE_ALERT,
      Ti.App.iOS.USER_NOTIFICATION_TYPE_SOUND,
      Ti.App.iOS.USER_NOTIFICATION_TYPE_BADGE
    ]
  });
}
