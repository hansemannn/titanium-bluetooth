package ti.bluetooth;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.common.Log;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;

public final class TiBluetoothGattCallbackHandler extends BluetoothGattCallback {
	private static final String LCAT = TiBluetoothModule.LCAT;

	private KrollProxy proxy;

	public TiBluetoothGattCallbackHandler(KrollProxy proxy) {
		super();
		this.proxy = proxy;
	}

	    @Override
        public void onConnectionStateChange(final BluetoothGatt gatt, final int status, final int newState) {
            // this will get called when a device connects or disconnects
            Log.i(LCAT, "connected/disconnected " + status);
            gatt.discoverServices();
        }

	@Override
	public void onServicesDiscovered(final BluetoothGatt gatt, final int status) {
		// this will get called after the client initiates a
		// BluetoothGatt.discoverServices() call
		BluetoothDevice device = gatt.getDevice();
		KrollDict kdServices = new KrollDict();
		KrollDict kdCharacteristics = new KrollDict();

		List<BluetoothGattService> services = gatt.getServices();
		kdServices.put("device", device.getAddress());
		kdCharacteristics.put("device", device.getAddress());

		//Log.i(LCAT, device.getAddress() + " services count: " + services.size());

		HashMap listServices = new HashMap();
		HashMap<String, Object> hashChar = new HashMap<String, Object>();

		for (BluetoothGattService service : services) {
			//Log.i(LCAT, "Service: " + service.getType() + " " + service.getUuid());

			HashMap<String, Object> listService = new HashMap<String, Object>();
			listService.put("serviceType", service.getType());
			listService.put("serviceUuid", service.getUuid().toString());
			listServices.put("services", listService);

			HashMap listChars = new HashMap();
			List<BluetoothGattCharacteristic> characteristics = service.getCharacteristics();
			for (BluetoothGattCharacteristic btc : characteristics) {
				//Log.i(LCAT, "uuid: " + btc.getUuid());
				gatt.setCharacteristicNotification(btc, false);
				
				HashMap<String, Object> listChar = new HashMap<String, Object>();
				listChar.put("uuid", btc.getUuid().toString());
				listChar.put("value", btc.getValue());
				
				listChars.put("data", listChar);
				// TODO not needed at the moment
				// byte[] data = btc.getValue();
				// if (data != null && data.length > 0) {
				//     final StringBuilder stringBuilder = new StringBuilder(data.length);
				//     for (byte byteChar : data) {
				//         stringBuilder.append(String.format("%02X ", byteChar));
				//     }
				// 
				//     Log.i(LCAT, "String val: " + btc.getUuid() + " " + btc.getValue() + " " + stringBuilder.toString());
				// }
				gatt.readCharacteristic(btc);
				
				for (BluetoothGattDescriptor descriptor : btc.getDescriptors()) {
					// find descriptor UUID that matches Client Characteristic
					// Configuration (0x2902)
					// and then call setValue on that descriptor
					
					// Log.i(LCAT, "uuid: " + descriptor.getUuid() + " value: " +  descriptor.getValue());
					// descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
					// gatt.writeDescriptor(descriptor);
					Log.d(LCAT, "[BluetoothLEService] ----- Enabled NOTIFICATION Descriptor : " + descriptor.getUuid());
					BluetoothGattDescriptor readDescriptor = btc.getDescriptor(descriptor.getUuid());
                    readDescriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
					gatt.writeDescriptor(descriptor);
				}
			}
			hashChar.put("seriveUuid",service.getUuid().toString());
			hashChar.put("chars",listChars);
		}
		kdServices.put("services", listServices);
		kdCharacteristics.put("characteristics", hashChar);

		proxy.fireEvent("didDiscoverServices", kdServices);
		proxy.fireEvent("didDiscoverCharacteristicsForService", kdCharacteristics);
	}


	@Override
	public void onCharacteristicChanged(BluetoothGatt gatt, final BluetoothGattCharacteristic characteristic) {
		// this will get called anytime you perform a read or write
		// characteristic operation
		byte[] data = characteristic.getValue();
		Log.i(LCAT, "Char changed " + data.toString());
		
	}

}
