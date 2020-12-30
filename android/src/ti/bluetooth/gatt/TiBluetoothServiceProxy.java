package ti.bluetooth.gatt;

import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import java.util.ArrayList;
import java.util.List;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import ti.bluetooth.TiBluetoothModule;

@Kroll.proxy(parentModule = TiBluetoothModule.class)
public class TiBluetoothServiceProxy extends KrollProxy {
  private BluetoothGattService bluetoothGattService;
  private List<TiBluetoothCharacteristicProxy> characteristics;

  public TiBluetoothServiceProxy(BluetoothGattService bluetoothGattService) {
    this.bluetoothGattService = bluetoothGattService;
    this.characteristics =
        mapCharacteristics(bluetoothGattService.getCharacteristics());
  }

  private List<TiBluetoothCharacteristicProxy>
  mapCharacteristics(List<BluetoothGattCharacteristic> characteristics) {
    List<TiBluetoothCharacteristicProxy> characteristicList = new ArrayList<>();

    for (BluetoothGattCharacteristic characteristic : characteristics) {
      characteristicList.add(
          new TiBluetoothCharacteristicProxy(characteristic));
    }

    return characteristicList;
  }

  public List<TiBluetoothCharacteristicProxy> getCharacteristicsList() {
    return characteristics;
  }

  @Kroll.getProperty
  @Kroll.method
  public Object[] getCharacteristics() {
    return characteristics.toArray();
  }

  @Kroll.getProperty
  @Kroll.method
  public String getUuid() {
    return bluetoothGattService.getUuid().toString().toUpperCase();
  }
}
