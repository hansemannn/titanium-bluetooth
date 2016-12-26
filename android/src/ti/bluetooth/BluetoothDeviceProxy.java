package ti.bluetooth;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiApplication;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothSocket;
import android.content.Context;

public class BluetoothDeviceProxy extends KrollProxy {
	private BluetoothDevice btDevice;
	private Context ctx;
	final String LCAT = TiBluetoothModule.LCAT;

	public BluetoothDeviceProxy(BluetoothDevice btDevice) {
		super();
		ctx = TiApplication.getInstance();
		this.btDevice = btDevice;
	}

	@Kroll.method
	public void connectGatt(boolean autoConnect) {
		btDevice.connectGatt(ctx, autoConnect, btleGattCallback);
	}

	@Kroll.method
	public void createBond() {
		btDevice.createBond();
	}

	@Kroll.method
	public BluetoothSocket createInsecureRfcommSocketToServiceRecord(String uuid) {
		BluetoothSocket btSocket = null;
		try {
			btSocket = btDevice.createInsecureRfcommSocketToServiceRecord(UUID
					.fromString(uuid));
		} catch (IOException e) {
			e.printStackTrace();
		}
		return btSocket;
	}

	@Kroll.method
	public BluetoothSocket createRfcommSocketToServiceRecord(String uuid) {
		BluetoothSocket btSocket = null;
		try {
			btSocket = btDevice.createRfcommSocketToServiceRecord(UUID
					.fromString(uuid));
		} catch (IOException e) {
			e.printStackTrace();
		}
		return btSocket;
	}

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

}
