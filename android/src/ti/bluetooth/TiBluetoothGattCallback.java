package ti.bluetooth;

import java.util.List;

import org.appcelerator.kroll.common.Log;

import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;

public final class TiBluetoothGattCallback extends BluetoothGattCallback {
	private static final String LCAT = TiBluetoothModule.LCAT;

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
	public void onServicesDiscovered(final BluetoothGatt gatt, final int status) {
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
						stringBuilder.append(String.format("%02X ", byteChar));
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
}
