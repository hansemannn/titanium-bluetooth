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
		btDevice.connectGatt(ctx, autoConnect, new TiBluetoothGattCallback());
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

}
