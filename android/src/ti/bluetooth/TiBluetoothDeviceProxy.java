package ti.bluetooth;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiApplication;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Context;
import android.os.ParcelUuid;

@Kroll.proxy(parentModule = TiBluetoothModule.class)
public class TiBluetoothDeviceProxy extends KrollProxy {

	private BluetoothDevice btDevice;
	private Context ctx;
	final String LCAT = TiBluetoothModule.LCAT;

	public TiBluetoothDeviceProxy(BluetoothDevice btDevice) {
		super();
		ctx = TiApplication.getInstance();
		this.btDevice = btDevice;
	}

	@Kroll.method
	public void connectGatt(boolean autoConnect) {
		btDevice.connectGatt(ctx, autoConnect, new BluetoothGattCallbackHandler(this));
	}

	// Get the friendly Bluetooth name of the remote device.
	@Kroll.method
	public String getName() {
		return btDevice.getName();
	}

	// Returns the hardware address of this BluetoothDevice.
	@Kroll.method
	public String getAddress() {
		return btDevice.getAddress();
	}

	// Get the Bluetooth device type of the remote device.
	// Possible are: the device type DEVICE_TYPE_CLASSIC, DEVICE_TYPE_LE
	// DEVICE_TYPE_DUAL. DEVICE_TYPE_UNKNOWN if it's not available
	@Kroll.method
	public int getType() {
		return btDevice.getType();
	}

	// Get the bond state of the remote device.
	// Possible values for the bond state are: BOND_NONE, BOND_BONDING,
	// BOND_BONDED.
	@Kroll.method
	public int getBondState() {
		return btDevice.getBondState();
	}

	// Returns the supported features (UUIDs) of the remote device.
	// This method does not start a service discovery procedure to retrieve the
	// UUIDs from the remote device. Instead, the local cached copy of the
	// service UUIDs are returned.
	@Kroll.method
	public Object[] getUuids() {
		List<String> uuids = new ArrayList<String>();
		ParcelUuid[] puuids = btDevice.getUuids();
		if (puuids != null && puuids.length > 0) {
			for (ParcelUuid pid : puuids) {
				uuids.add(pid.toString());
			}
		}
		return uuids.toArray();
	}

	@Kroll.method
	public void createBond() {
		btDevice.createBond();
	}

	@Kroll.method
	public boolean fetchUuidsWithSdp() {
		return btDevice.fetchUuidsWithSdp();
	}
}
