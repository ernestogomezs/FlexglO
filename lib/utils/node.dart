import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const String DEF_ID = "00000000-0000-0000-0000-000000000000";

class Node{
  late int id;
  late BluetoothDevice device;
  late BluetoothService service;
  late ValueNotifier<String> serviceUuidNotifier = ValueNotifier<String> ("XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"); 

  late BluetoothCharacteristic flexCharacteristic;
  late StreamSubscription<List<int>> lastFlexSub;
  late ValueNotifier<List<int>> flexBytesNotifier = ValueNotifier<List<int>>([]);
  
  late BluetoothCharacteristic gloCharacteristic;
  late StreamSubscription<List<int>> lastGloSub;
  late ValueNotifier<List<int>> gloBytesNotifier;

  late StreamSubscription<List<int>> connectionStateSub;
  late ValueNotifier<bool> connectionStateNotifier = ValueNotifier<bool>(isConnected);


  Node.def(this.id){
    device = BluetoothDevice.fromId(DEF_ID);
  }

  Node(this.device); 

  void init() async{
    id = int.parse(device.platformName.substring(device.platformName.length - 1));
    List<BluetoothService> services = await device.discoverServices();
    service = services[0];
    serviceUuidNotifier.value = service.serviceUuid.toString();

    flexCharacteristic = service.characteristics[0];

    print(service.toString());
    print(flexCharacteristic.toString());

    final connectionStateSub = device.connectionState.listen((state) {
      connectionStateNotifier.value = state == BluetoothConnectionState.connected;
    });

    final lastFlexSub = flexCharacteristic.onValueReceived.listen((valuein) {
      print(valuein);      
      flexBytesNotifier.value = valuein;
    });
    device.cancelWhenDisconnected(lastFlexSub);
    flexCharacteristic.setNotifyValue(true);

    // gloCharacteristic = service.characteristics[1];
    // final lastGloSub = colorCharacteristic.lastValueStream.listen((value) {
    //   colorbytes = value;
    // });
    // device.cancelWhenDisconnected(_lastColorSubscription);
    //await colorCharacteristic.setNotifyValue(true);
  }

  bool get isConnected {
    return (device.remoteId.toString() == DEF_ID)? device.isConnected : false;
  } 

  // get flex{
  //   flexCharacteristic.read();
  //   return flexBytes;
  // }

  // get color{
  //   gloCharacteristic.read();
  //   return gloBytes;
  // }
}