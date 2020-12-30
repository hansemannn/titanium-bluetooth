package ti.bluetooth.central;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanRecord;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.content.IntentFilter;
import android.os.ParcelUuid;
import java.util.ArrayList;
import java.util.List;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import ti.bluetooth.TiBluetoothModule;
import ti.bluetooth.broadcastReceiver.TiBluetoohBroadcastReceiver;
import ti.bluetooth.listener.OnBluetoothStateChangedListener;
import ti.bluetooth.listener.OnPeripheralConnectionStateChangedListener;
import ti.bluetooth.peripheral.TiBluetoothPeripheralProxy;

@Kroll.proxy(parentModule = TiBluetoothModule.class)
public class TiBluetoothCentralManagerProxy
    extends KrollProxy implements OnBluetoothStateChangedListener,
                                  OnPeripheralConnectionStateChangedListener {
  private static final String DID_UPDATE_STATE_EVENT = "didUpdateState";
  private static final String DID_DISCOVER_PERIPHERAL = "didDiscoverPeripheral";
  private static final String ERROR_SCAN_FAILED = "errorScanFailed";
  private static final String DID_CONNECT_PERIPHERAL = "didConnectPeripheral";
  private static final String DID_DISCONNECT_PERIPHERAL =
      "didDisconnectPeripheral";
  private static final String DID_FAIL_TO_CONNECT_PERIPHERAL =
      "didFailToConnectPeripheral";
  private static final String NOTIFY_ON_CONNECTION_KEY = "notifyOnConnection";
  private static final String NOTIFY_ON_DISCONNECTION_KEY =
      "notifyOnDisconnection";

  private static final int SCAN_MODE_BALANCED =
      TiBluetoothModule.SCAN_MODE_BALANCED;
  private static final int SCAN_MODE_LOW_LATENCY =
      TiBluetoothModule.SCAN_MODE_LOW_LATENCY;
  private static final int SCAN_MODE_LOW_POWER =
      TiBluetoothModule.SCAN_MODE_LOW_POWER;
  private static final int SCAN_MODE_OPPORTUNISTIC =
      TiBluetoothModule.SCAN_MODE_OPPORTUNISTIC;

  private Context context;
  private BluetoothAdapter bluetoothAdapter;
  private int scanMode;
  private int bluetoothState;

  private boolean isScanning;

  public TiBluetoothCentralManagerProxy(Context context,
                                        BluetoothAdapter bluetoothAdapter) {
    this.context = context;
    this.bluetoothAdapter = bluetoothAdapter;
    this.bluetoothState = bluetoothAdapter.getState();
    this.scanMode = ScanSettings.SCAN_MODE_BALANCED;

    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED);

    context.registerReceiver(new TiBluetoohBroadcastReceiver(this),
                             intentFilter);
  }

  @Kroll.method
  public boolean isScanning() {
    return isScanning;
  }

  @Kroll.method
  public void startScan() {
    startScanWithServices(null);
  }

  @Kroll.method
  public void startScanWithServices(String[] services) {
    ScanSettings settings =
        new ScanSettings.Builder().setScanMode(scanMode).build();

    List<ScanFilter> filters = buildScanFilters(services);
    bluetoothAdapter.getBluetoothLeScanner().startScan(filters, settings,
                                                       scanCallback);
    isScanning = true;
  }

  @Kroll.method
  public void stopScan() {
    bluetoothAdapter.getBluetoothLeScanner().stopScan(scanCallback);
    isScanning = false;
  }

  @Kroll.method
  public void
  connectPeripheral(TiBluetoothPeripheralProxy peripheral,
                    @Kroll.argument(optional = true) KrollDict properties) {
    boolean notifyOnConnection =
        properties.getBoolean(NOTIFY_ON_CONNECTION_KEY);
    boolean notifyOnDisconnection =
        properties.getBoolean(NOTIFY_ON_DISCONNECTION_KEY);

    peripheral.connectPeripheral(context, notifyOnConnection,
                                 notifyOnDisconnection, this);
  }

  @Override
  public void
  onPeripheralConnectionStateConnected(TiBluetoothPeripheralProxy peripheral) {
    fireCentralManagerEvent(DID_CONNECT_PERIPHERAL, peripheral);
  }

  @Override
  public void onPeripheralConnectionStateDisconnected(
      TiBluetoothPeripheralProxy peripheral) {
    fireCentralManagerEvent(DID_DISCONNECT_PERIPHERAL, peripheral);
  }

  @Override
  public void
  onPeripheralConnectionStateError(TiBluetoothPeripheralProxy peripheral) {
    fireCentralManagerEvent(DID_FAIL_TO_CONNECT_PERIPHERAL, peripheral);
  }

  @Kroll.method
  public void
  cancelPeripheralConnection(TiBluetoothPeripheralProxy peripheral) {
    peripheral.disconnectPeripheral();
  }

  @Kroll.getProperty
  @Kroll.method
  public int getScanMode() {
    return scanMode;
  }

  @Kroll.setProperty
  @Kroll.method
  public void setScanMode(int scanMode) {
    if (scanMode == SCAN_MODE_BALANCED || scanMode == SCAN_MODE_LOW_LATENCY ||
        scanMode == SCAN_MODE_LOW_POWER ||
        scanMode == SCAN_MODE_OPPORTUNISTIC) {
      this.scanMode = scanMode;
    }
  }

  @Kroll.getProperty
  @Kroll.method
  public int getState() {
    return bluetoothState;
  }

  private List<ScanFilter> buildScanFilters(String[] serviceUuids) {
    List<ScanFilter> filterList = new ArrayList<>();

    if (serviceUuids != null && serviceUuids.length > 0) {
      for (int i = 0; i < serviceUuids.length; i++) {
        ScanFilter filter =
            new ScanFilter.Builder()
                .setServiceUuid(ParcelUuid.fromString(serviceUuids[i]))
                .build();
        filterList.add(filter);
      }
    }

    return filterList;
  }

  private final ScanCallback scanCallback = new ScanCallback() {
    @Override
    public void onScanResult(int callbackType, ScanResult scanResult) {
      super.onScanResult(callbackType, scanResult);
      processResult(scanResult);
    }

    @Override
    public void onBatchScanResults(List<ScanResult> results) {
      super.onBatchScanResults(results);

      for (ScanResult scanResult : results) {
        processResult(scanResult);
      }
    }

    @Override
    public void onScanFailed(int errorCode) {
      super.onScanFailed(errorCode);
      fireEvent(ERROR_SCAN_FAILED, errorCode);
    }
  };

  private void processResult(ScanResult result) {
    TiBluetoothPeripheralProxy bluetoothPeripheral =
        new TiBluetoothPeripheralProxy(result.getDevice(),
                                       result.getScanRecord());
    fireCentralManagerEvent(DID_DISCOVER_PERIPHERAL, bluetoothPeripheral);
  }

  private void
  fireCentralManagerEvent(String event,
                          TiBluetoothPeripheralProxy bluetoothPeripheral) {
    KrollDict kd = new KrollDict();
    kd.put("peripheral", bluetoothPeripheral);

    fireEvent(event, kd);
  }

  @Override
  public void onBluetoothStateChanged() {
    switch (bluetoothAdapter.getState()) {
    case BluetoothAdapter.STATE_TURNING_OFF:
      bluetoothState = TiBluetoothModule.MANAGER_STATE_POWERED_OFF;
      break;
    case BluetoothAdapter.STATE_OFF:
      bluetoothState = TiBluetoothModule.MANAGER_STATE_POWERED_OFF;
      break;
    case BluetoothAdapter.STATE_ON:
      bluetoothState = TiBluetoothModule.MANAGER_STATE_POWERED_ON;
      break;
    }

    KrollDict kd = new KrollDict();
    kd.put("state", bluetoothState);

    fireEvent(DID_UPDATE_STATE_EVENT, kd);
  }
}
