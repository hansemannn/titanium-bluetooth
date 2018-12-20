package ti.bluetooth.gatt;

import android.bluetooth.BluetoothGattCharacteristic;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiBlob;

import ti.bluetooth.TiBluetoothModule;

@Kroll.proxy(parentModule = TiBluetoothModule.class)
public class TiBluetoothCharacteristicProxy extends KrollProxy {
  private BluetoothGattCharacteristic characteristic;

  public TiBluetoothCharacteristicProxy(
      BluetoothGattCharacteristic characteristic) {
    this.characteristic = characteristic;
  }

  @Kroll
      .getProperty
      @Kroll.method
      public String getUuid() {
    return characteristic.getUuid().toString().toUpperCase();
  }

  @Kroll
      .getProperty
      @Kroll.method
      public TiBlob getValue() {
    return TiBlob.blobFromData(characteristic.getValue());
  }

  public BluetoothGattCharacteristic getCharacteristic() {
    return characteristic;
  }
}
