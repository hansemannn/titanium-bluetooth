/**
 * This file was auto-generated by the Titanium Module SDK helper for Android
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package ti.bluetooth;

import java.util.ArrayList;
import java.util.List;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiConfig;
import org.appcelerator.titanium.TiApplication;

import android.bluetooth.BluetoothProfile;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.ParcelUuid;

@Kroll.module(name = "TiBluetooth", id = "ti.bluetooth")
public class TiBluetoothModule extends KrollModule {

	public interface ConnectionCallback {
		void onConnectionStateChange(BluetoothDevice device, int newState);
	}

	public static final String LCAT = "BLE";
	private static int kJobId = 0;
	private BluetoothManager btManager;
	private BluetoothAdapter btAdapter;
	private TiApplication appContext;
	private Activity activity;
	private KrollFunction onFound;
	private KrollFunction onConnections;
	private BluetoothLeScanner btScanner;

	private int currentState = 0;
	private boolean isScanning = false;

	@Kroll.constant
	public static final int MANAGER_STATE_UNKNOWN = 0;
	@Kroll.constant
	public static final int MANAGER_STATE_UNSUPPORTED = 1;
	@Kroll.constant
	public static final int MANAGER_STATE_UNAUTHORIZED = 2;
	@Kroll.constant
	public static final int MANAGER_STATE_POWERED_OFF = 10;
	@Kroll.constant
	public static final int MANAGER_STATE_POWERED_ON = 12;
	@Kroll.constant
	public static final int MANAGER_STATE_RESETTING = 5;

	@Kroll.constant
	public static final int SCAN_MODE_BALANCED = ScanSettings.SCAN_MODE_BALANCED;
	@Kroll.constant
	public static final int SCAN_MODE_LOW_LATENCY = ScanSettings.SCAN_MODE_LOW_LATENCY;
	@Kroll.constant
	public static final int SCAN_MODE_LOW_POWER = ScanSettings.SCAN_MODE_LOW_POWER;
	@Kroll.constant
	public static final int SCAN_MODE_OPPORTUNISTIC = ScanSettings.SCAN_MODE_OPPORTUNISTIC;

	@Kroll.constant
	public static final int PROFILE_ADP = BluetoothProfile.A2DP;

	@Kroll.constant
	public static final int PROFILE_HEADSET = BluetoothProfile.HEADSET;
	@Kroll.constant
	public static final int PROFILE_HEALTH = BluetoothProfile.HEALTH;

	@Kroll.constant
	public static final int DEVICE_BOND_BONDED = BluetoothDevice.BOND_BONDED;
	@Kroll.constant
	public static final int DEVICE_BOND_BONDING = BluetoothDevice.BOND_BONDING;
	@Kroll.constant
	public static final int DEVICE_BOND_NONE = BluetoothDevice.BOND_NONE;

	public final int DEFAULT_SCAN_MODE = SCAN_MODE_BALANCED;
	private int scanmode = DEFAULT_SCAN_MODE;

	public TiBluetoothModule() {
		super();
		appContext = TiApplication.getInstance();
		activity = appContext.getCurrentActivity();
		appContext.registerReceiver(mReceiver, new IntentFilter(
				BluetoothAdapter.ACTION_STATE_CHANGED));
	}

	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app) {
		Log.d(LCAT, "inside onAppCreate");
	}

	private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			// It means the user has changed his bluetooth state.
			if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
				if (btAdapter.getState() == BluetoothAdapter.STATE_TURNING_OFF) {
					// The user bluetooth is turning off yet, but it is not
					// disabled yet.
					currentState = MANAGER_STATE_POWERED_OFF;
				}

				if (btAdapter.getState() == BluetoothAdapter.STATE_OFF) {
					// The user bluetooth is already disabled.
					currentState = MANAGER_STATE_POWERED_OFF;
				}
				if (btAdapter.getState() == BluetoothAdapter.STATE_ON) {
					// The user bluetooth is already disabled.
					currentState = MANAGER_STATE_POWERED_ON;
				}
				KrollDict kd = new KrollDict();
				kd.put("state", btAdapter.getState());
				kd.put("address", btAdapter.getAddress());
				kd.put("name", btAdapter.getName());
				kd.put("discovering", btAdapter.isDiscovering());
				kd.put("enabled", btAdapter.isEnabled());
				kd.put("multipleAdvertisementSupported",
						btAdapter.isMultipleAdvertisementSupported());
				kd.put("offloadedFilteringSupported",
						btAdapter.isOffloadedFilteringSupported());
				kd.put("offloadedScanBatchingSupported",
						btAdapter.isOffloadedScanBatchingSupported());
				fireEvent("didUpdateState", kd);
			}
		}
	};

	private final ScanCallback scanCallback = new ScanCallback() {
		@Override
		public void onScanResult(int callbackType, ScanResult result) {
			BluetoothDevice device = result.getDevice();
			if (device != null) {
				device.Log.d(LCAT, "Found something " + device.getName());
				if (device.getName() != null) {
					Log.d(LCAT,
							"Found: " + device.getName() + " "
									+ device.getAddress());
					ArrayList<String> ids = new ArrayList<String>();
					for (ParcelUuid id : device.getUuids()) {
						ids.add(id.toString());
					}
					KrollDict kd = new KrollDict();
					kd.put("name", device.getName());
					kd.put("address", device.getAddress());
					kd.put("bondState", device.getBondState());
					kd.put("ids", ids.toArray());

					fireEvent("didDiscoverPeripheral", kd);
					BluetoothGatt bluetoothGatt = device.connectGatt(
							appContext, false, btleGattCallback);
					btScanner.stopScan(scanCallback);
				}
			}
		}
	};

	private final BluetoothGattCallback btleGattCallback = new BluetoothGattCallback() {

		@Override
		public void onCharacteristicChanged(BluetoothGatt gatt,
				final BluetoothGattCharacteristic characteristic) {
			// this will get called anytime you perform a read or write
			// characteristic operation
			byte[] data = characteristic.getValue();
			Log.i(LCAT, "Char changed " + data.toString());
			for (BluetoothGattDescriptor descriptor : characteristic
					.getDescriptors()) {
				// find descriptor UUID that matches Client Characteristic
				// Configuration (0x2902)
				// and then call setValue on that descriptor
				descriptor
						.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
				// bluetoothGatt.writeDescriptor(descriptor);
			}
		}

		@Override
		public void onConnectionStateChange(final BluetoothGatt gatt,
				final int status, final int newState) {
			// this will get called when a device connects or disconnects
			Log.i(LCAT, "connected/disconnected " + status);
			gatt.discoverServices();
		}

		@Override
		public void onServicesDiscovered(final BluetoothGatt gatt,
				final int status) {
			// this will get called after the client initiates a
			// BluetoothGatt.discoverServices() call

			List<BluetoothGattService> services = gatt.getServices();
			Log.i(LCAT, "Services: " + services.size());
			for (BluetoothGattService service : services) {
				List<BluetoothGattCharacteristic> characteristics = service
						.getCharacteristics();
				for (BluetoothGattCharacteristic btc : characteristics) {
					Log.i(LCAT, "uuid: " + btc.getUuid());
					byte[] data = btc.getValue();
					if (data != null && data.length > 0) {
						final StringBuilder stringBuilder = new StringBuilder(
								data.length);
						for (byte byteChar : data) {
							stringBuilder.append(String.format("%02X ",
									byteChar));
						}

						Log.i(LCAT,
								"String val: " + btc.getUuid() + " "
										+ btc.getValue() + " "
										+ stringBuilder.toString());
					}
					gatt.readCharacteristic(btc);
				}

			}
		}
	};

	@Kroll.method
	public int getState() {
		return currentState;
	}

	@Kroll.method
	public boolean isScanning() {
		return isScanning;
	}

	@Kroll.method
	public void initialize() {
		btManager = (BluetoothManager) appContext
				.getSystemService(Context.BLUETOOTH_SERVICE);
		btAdapter = btManager.getAdapter();
		if (btAdapter != null) {
			Log.d(LCAT, "BT init");
			currentState = btAdapter.getState();
		} else {
			currentState = MANAGER_STATE_UNSUPPORTED;
		}
	}

	@Kroll.method
	public void startScan() {
		startScan(scanmode);
	}

	@Kroll.method
	public void startScan(int _scanmode) {
		if (btAdapter != null) {
			ScanSettings scanSettings = new ScanSettings.Builder().setScanMode(
					_scanmode).build();
			btScanner = btAdapter.getBluetoothLeScanner();
			btScanner.startScan(scanFilters(), scanSettings, scanCallback);
			// btScanner.startScan(scanCallback);
			isScanning = true;
		}
	}

	private List<ScanFilter> scanFilters() {
		String[] ids = {};
		return scanFilters(ids);
	}

	private List<ScanFilter> scanFilters(String[] ids) {
		List<ScanFilter> list = new ArrayList<ScanFilter>(1);
		for (int i = 0; i < ids.length; i++) {
			ScanFilter filter = new ScanFilter.Builder().setServiceUuid(
					ParcelUuid.fromString(ids[i])).build();
			list.add(filter);
		}
		return list;
	}

	@Kroll.method
	public void startScanWithServices(String[] ids) {
		if (btAdapter != null) {
			ScanSettings settings = new ScanSettings.Builder().setScanMode(
					ScanSettings.SCAN_MODE_BALANCED).build();
			btScanner = btAdapter.getBluetoothLeScanner();
			btScanner.startScan(scanFilters(ids), settings, scanCallback);
			isScanning = true;
		}
	}

	// @Override
	// public void eventListenerAdded(String eventName, int count, KrollProxy
	// proxy) {
	// super.eventListenerAdded(eventName, count, proxy);
	//
	// if (eventName.equals("didDiscoverPeripheral")) {
	//
	// }
	// }

	@Kroll.method
	public void setScanMode(int sm) {
		scanmode = sm;
	}

	@Kroll.method
	public int getScanMode() {
		return scanmode;
	}

	@Kroll.method
	public void stopScan() {
		if (btAdapter != null) {
			btScanner.stopScan(scanCallback);
			isScanning = false;
		}
	}

	@Kroll.method
	public void flushPendingScanResults() {
		if (btAdapter != null) {
			btScanner.flushPendingScanResults(scanCallback);
			// isScanning = false;
		}
	}

}
