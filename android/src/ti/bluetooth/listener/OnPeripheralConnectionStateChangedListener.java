package ti.bluetooth.listener;

import ti.bluetooth.peripheral.TiBluetoothPeripheralProxy;

public interface OnPeripheralConnectionStateChangedListener {
  void
  onPeripheralConnectionStateConnected(TiBluetoothPeripheralProxy peripheral);
  void onPeripheralConnectionStateDisconnected(
      TiBluetoothPeripheralProxy peripheral);
  void onPeripheralConnectionStateError(TiBluetoothPeripheralProxy peripheral);
}
