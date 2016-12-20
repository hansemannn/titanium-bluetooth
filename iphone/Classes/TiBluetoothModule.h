/**
 * ti.bluetooth
 *
 * Created by Hans Knoechel
 * Copyright (c) 2016 Your Company. All rights reserved.
 */

#import "TiModule.h"

@class CBCentralManager, CBPeripheral;

@interface TiBluetoothModule : TiModule <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *centralManager;
    CBPeripheral *polarH7HRMPeripheral;
}

@end
