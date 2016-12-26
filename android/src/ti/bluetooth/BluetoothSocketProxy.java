package ti.bluetooth;

import java.io.IOException;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import android.bluetooth.BluetoothSocket;

public class BluetoothSocketProxy extends KrollProxy {
	BluetoothSocket btSocket;

	public BluetoothSocketProxy(BluetoothSocket btSocket) {
		super();
		this.btSocket = btSocket;
	}

	@Kroll.method
	public void connect() {
		try {
			btSocket.connect();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	@Kroll.method
	public void close() {
		try {
			btSocket.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	@Kroll.method
	public int getConnectionType() {
		return btSocket.getConnectionType();
	}

	@Kroll.method
	public int getMaxReceivePacketSize() {
		return btSocket.getMaxReceivePacketSize();
	}

	@Kroll.method
	public int getMaxTransmitPacketSize() {
		return btSocket.getMaxTransmitPacketSize();
	}

	@Kroll.method
	public boolean isConnected() {
		return btSocket.isConnected();
	}
}
