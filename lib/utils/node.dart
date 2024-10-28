import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Node{
  late int id;
  late BluetoothDevice device;
  late BluetoothService service;

  late BluetoothCharacteristic valueCharacteristic;
  late StreamSubscription<List<int>> _lastValueSubscription;
  List<int> valuebytes = [];
  final ValueNotifier<List<int>> valuebytesL = ValueNotifier<List<int>>([]);
  
  // late BluetoothCharacteristic colorCharacteristic;
  // late StreamSubscription<List<int>> _lastColorSubscription;
  // List<int> colorbytes = [];

  Node.def(this.id){
    device = BluetoothDevice.fromId("e006b3a7-ef7b-4980-a668-1f8005f84383");
  }

  Node(this.device); 

  void init() async{
    id = int.parse(device.platformName.substring(device.platformName.length - 1));
    List<BluetoothService> services = await device.discoverServices();
    service = services[0];

    valueCharacteristic = service.characteristics[0];
    final _lastValueSubscription = valueCharacteristic.lastValueStream.listen((valuein) {
      print(valuein);      
      valuebytesL.value = valuein;
    });
    device.cancelWhenDisconnected(_lastValueSubscription);
    // await valueCharacteristic.setNotifyValue(true);

    // colorCharacteristic = service.characteristics[1];
    // final _lastColorSubscription = colorCharacteristic.lastValueStream.listen((value) {
    //   colorbytes = value;
    // });
    // device.cancelWhenDisconnected(_lastColorSubscription);
    //await colorCharacteristic.setNotifyValue(true);
  }

  bool get isConnected => device.isConnected;

  get value{
    valueCharacteristic.read();
    return valuebytes;
  }

  // get color{
  //   colorCharacteristic.read();
  //   return colorbytes;
  // }
}