package ti.bluetooth;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.common.Log;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public final class TiBluetoohBroadcastReceiver extends BroadcastReceiver {
	BluetoothAdapter btAdapter;
	TiBluetoothModule module;

	public TiBluetoohBroadcastReceiver(TiBluetoothModule module, BluetoothAdapter btAdapter) {
		super();
		this.btAdapter = btAdapter;
		this.module = module;
	}

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
            // It means the user has changed his bluetooth state.
            if (btAdapter.getState() == BluetoothAdapter.STATE_TURNING_OFF) {
                // The user bluetooth is turning off yet, but it is not disabled yet.
                module.setCurrentState(TiBluetoothModule.MANAGER_STATE_POWERED_OFF);
            } else if (btAdapter.getState() == BluetoothAdapter.STATE_OFF) {
                // The user bluetooth is already disabled.
                module.setCurrentState(TiBluetoothModule.MANAGER_STATE_POWERED_OFF);
            } else if (btAdapter.getState() == BluetoothAdapter.STATE_ON) {
                // The user bluetooth is already disabled.
                module.setCurrentState(TiBluetoothModule.MANAGER_STATE_POWERED_ON);
            }

            KrollDict kd = new KrollDict();
            kd.put("state", btAdapter.getState());
            module.fireEvent("didUpdateState", kd);
        } else if (action.equals(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)) {
			Log.i(module.LCAT, "Discovery finished");
		} else if (action.equals(BluetoothDevice.ACTION_FOUND)) {
			Log.i(module.LCAT, "Action found");
		}
    }
};
