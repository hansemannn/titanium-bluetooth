/**
 * ti.bluetooth
 *
 * Created by Hans Knoechel
 * Copyright (c) 2016 Your Company. All rights reserved.
 */

#import "TiModule.h"

@class CBCentralManager, CBPeripheralManager, CBPeripheral;

@interface TiBluetoothModule : TiModule <CBPeripheralDelegate>
{

}

@end
