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

  @Kroll.getProperty
  public String getUuid() {
    return characteristic.getUuid().toString().toUpperCase();
  }

  @Kroll.getProperty
  public TiBlob getValue() {
    return TiBlob.blobFromData(characteristic.getValue());
  }

  @Kroll.getProperty
  public int getCharacteristicProperties() {
    return characteristic.getProperties();
  }

  @Kroll.getProperty
  public int getPermissions() {
    return characteristic.getPermissions();
  }

  public BluetoothGattCharacteristic getCharacteristic() {
    return characteristic;
  }
}
