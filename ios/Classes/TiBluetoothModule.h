/**
 * ti.bluetooth
 *
 * Created by Hans Knoechel
 * Copyright (c) 2016 Your Company. All rights reserved.
 */

#import "TiModule.h"

@class CBCentralManager, CBPeripheralManager, CBPeripheral;

@interface TiBluetoothModule : TiModule <CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *centralManager;
    CBPeripheralManager *peripheralManager;
}

@end
