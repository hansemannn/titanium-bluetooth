package ti.bluetooth;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.KrollProxy;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public final class BlutoothStateChangedBroadcastReceiver extends
		BroadcastReceiver {
	BluetoothAdapter btAdapter;
	TiBluetoothModule module;

	public BlutoothStateChangedBroadcastReceiver(TiBluetoothModule module,
			BluetoothAdapter btAdapter) {
		super();
		this.btAdapter = btAdapter;
		this.module = module;
	}

	@Override
	public void onReceive(Context context, Intent intent) {
		String action = intent.getAction();
		// It means the user has changed his bluetooth state.
		if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
			if (btAdapter.getState() == BluetoothAdapter.STATE_TURNING_OFF) {
				// The user bluetooth is turning off yet, but it is not
				// disabled yet.
				module.setCurrentState(TiBluetoothModule.MANAGER_STATE_POWERED_OFF);

			}

			if (btAdapter.getState() == BluetoothAdapter.STATE_OFF) {
				// The user bluetooth is already disabled.
				module.setCurrentState(TiBluetoothModule.MANAGER_STATE_POWERED_OFF);
			}
			if (btAdapter.getState() == BluetoothAdapter.STATE_ON) {
				// The user bluetooth is already disabled.
				module.setCurrentState(TiBluetoothModule.MANAGER_STATE_POWERED_ON);
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
			if (module.hasListeners("didUpdateState"))
				module.fireEvent("didUpdateState", kd);
		}
	}
}