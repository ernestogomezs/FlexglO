import '/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Node{
  late int id;
  late BluetoothDevice device;
  late BluetoothService service;
  late ValueNotifier<String> serviceUuidNotifier = ValueNotifier<String>("XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"); 

  late BluetoothCharacteristic flexCharacteristic;
  late ValueNotifier<List<int>> flexBytesNotifier = ValueNotifier<List<int>>([]);

  late ValueNotifier<int> m0Notifier  = ValueNotifier<int>(0);
  late ValueNotifier<int> m1Notifier  = ValueNotifier<int>(0);
  late ValueNotifier<int> bpmNotifier = ValueNotifier<int>(0);
  
  late BluetoothCharacteristic gloCharacteristic;
  late ValueNotifier<List<int>> gloBytesNotifier = 
    ValueNotifier<List<int>>(DEFAULT_GLO);

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

    device.connectionState.listen((state) {
      connectionStateNotifier.value = isConnected;
    });

    var lastFlexSub = flexCharacteristic.onValueReceived.listen((valuein) {
      flexBytesNotifier.value = valuein;
      m0Notifier.value = valuein[1] << 8 | valuein[0];
      m1Notifier.value = valuein[3] << 8 | valuein[2];
      if(id == 0){
        bpmNotifier.value = valuein[5] << 8 | valuein[4];
      }
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

    gloCharacteristic = service.characteristics[1];
    var lastGloSub = gloCharacteristic.onValueReceived.listen((valuein) {
      gloBytesNotifier.value = valuein;
    });
    device.cancelWhenDisconnected(lastGloSub);
    try{
      await gloCharacteristic.setNotifyValue(true);
    }
    catch(e){
      if(e is FlutterBluePlusException){
        print("Stupid ahh bug, don't worry. Pops up when subscribing but shouldn't be a problem");
      }
    }

    await gloCharacteristic.write(gloBytesNotifier.value);
  }

  bool get isConnected {
    return (device.remoteId.toString() == DEFAULT_ID)? false : device.isConnected;
  } 

  void writeGloColor(Color currentColor, int muscleSite) async{
    List<int> gloMsg = List<int>.from(gloBytesNotifier.value);

    if(muscleSite == 0){
      gloMsg[0] = currentColor.red;
      gloMsg[1] = currentColor.green;
      gloMsg[2] = currentColor.blue;
    }
    else if(muscleSite == 1){
      gloMsg[3] = currentColor.red;
      gloMsg[4] = currentColor.green;
      gloMsg[5] = currentColor.blue;
    }
    gloBytesNotifier.value = gloMsg;
    await gloCharacteristic.write(gloMsg);
  }

  List<int> readGlo() {
    return gloBytesNotifier.value;
  }

  Color gloFromMuscle(int muscleSite){
    List<int> value = gloBytesNotifier.value;
    Color color;

    if(muscleSite == 0){
      color = Color.fromRGBO(value[0], value[1], value[2], 1.0);
    }
    else if(muscleSite == 1){
      color = Color.fromRGBO(value[3], value[4], value[5], 1.0);
    }
    else{
      throw "MuscleSite different than 0\\1";
    }

    return color;
  }

  void dispose(){
    serviceUuidNotifier.dispose();
    flexBytesNotifier.dispose();
    m0Notifier.dispose();
    m1Notifier.dispose();
    bpmNotifier.dispose();
    gloBytesNotifier.dispose();
    connectionStateNotifier.dispose();
  }
}