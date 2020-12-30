package ti.bluetooth.broadcastReceiver;

import android.bluetooth.BluetoothAdapter;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import ti.bluetooth.listener.OnBluetoothStateChangedListener;

public class TiBluetoohBroadcastReceiver extends BroadcastReceiver {
  private OnBluetoothStateChangedListener bluetoothStateChangedListener;

  public TiBluetoohBroadcastReceiver() { super(); }

  public TiBluetoohBroadcastReceiver(
      OnBluetoothStateChangedListener bluetoothStateChangedListener) {
    super();

    this.bluetoothStateChangedListener = bluetoothStateChangedListener;
  }

  @Override
  public void onReceive(Context context, Intent intent) {
    String action = intent.getAction();

    if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
      if (bluetoothStateChangedListener != null) {
        bluetoothStateChangedListener.onBluetoothStateChanged();
      }
    }
  }
};
