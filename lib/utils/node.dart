import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const String DEFAULT_ID = "00000000-0000-0000-0000-000000000000";

class Node{
  late int id;
  late BluetoothDevice device;
  late BluetoothService service;
  late ValueNotifier<String> serviceUuidNotifier = ValueNotifier<String> ("XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"); 

  late BluetoothCharacteristic flexCharacteristic;
  //late StreamSubscription<List<int>> lastFlexSub;
  late ValueNotifier<List<int>> flexBytesNotifier = ValueNotifier<List<int>>([]);

  late ValueNotifier<double> m0_Notifier    = ValueNotifier<double>(0.0);
  late ValueNotifier<double> m1_Notifier    = ValueNotifier<double>(0.0);
  late ValueNotifier<double> heart_Notifier = ValueNotifier<double>(0.0);
  
  late BluetoothCharacteristic gloCharacteristic;
  late StreamSubscription<List<int>> lastGloSub;
  late ValueNotifier<List<int>> gloBytesNotifier;

  //late StreamSubscription<List<int>> connectionStateSub;
  late ValueNotifier<bool> connectionStateNotifier = ValueNotifier<bool>(isConnected);


  Node.def(this.id){
    device = BluetoothDevice.fromId(DEFAULT_ID);
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

    device.connectionState.listen((state) {
      connectionStateNotifier.value = state == BluetoothConnectionState.connected;
    });

    var lastFlexSub = flexCharacteristic.onValueReceived.listen((valuein) {
      print(valuein);      
      flexBytesNotifier.value = valuein;
    });
    device.cancelWhenDisconnected(lastFlexSub);

    try{
      await flexCharacteristic.setNotifyValue(true); 
    }
    catch(e){
      if(e is FlutterBluePlusException){
        print("Stupid ahh bug, don't worry. Pops up when subscribing but shouldn't be a problem");
      }
    }

    // gloCharacteristic = service.characteristics[1];
    // final lastGloSub = colorCharacteristic.lastValueStream.listen((value) {
    //   colorbytes = value;
    // });
    // device.cancelWhenDisconnected(_lastColorSubscription);
    //await colorCharacteristic.setNotifyValue(true);
  }

  bool get isConnected {
    return (device.remoteId.toString() == DEFAULT_ID)? device.isConnected : false;
  } 

  // get flex{
  //   flexCharacteristic.read();
  //   return flexBytes;
  // }

  // get glo{
  //   gloCharacteristic.read();
  //   return gloBytes;
  // }
}