import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:namer_app/widgets/node_tile.dart';

class Node{
  late int id;
  late BluetoothDevice device;
  late BluetoothService service;

  late BluetoothCharacteristic valueCharacteristic;
  late StreamSubscription<List<int>> _lastValueSubscription;
  List<int> valuebytes = [];

  late BluetoothCharacteristic colorCharacteristic;
  late StreamSubscription<List<int>> _lastColorSubscription;
  List<int> colorbytes = [];

  Node(this.device); 
  
  void init() async{
    List<BluetoothService> services = await device.discoverServices();
    service = services[0];

    valueCharacteristic = service.characteristics[0];
    final _lastValueSubscription = valueCharacteristic.lastValueStream.listen((value) {
      valuebytes = value;
    });
    device.cancelWhenDisconnected(_lastValueSubscription);
    // await valueCharacteristic.setNotifyValue(true);

    colorCharacteristic = service.characteristics[1];
    final _lastColorSubscription = colorCharacteristic.lastValueStream.listen((value) {
      colorbytes = value;
    });
    device.cancelWhenDisconnected(_lastColorSubscription);
    //await colorCharacteristic.setNotifyValue(true);
  }

  bool get isConnected => device.isConnected;

  get value{
    valueCharacteristic.read();
    return valuebytes;
  }

  get color{
    colorCharacteristic.read();
    return colorbytes;
  }
}