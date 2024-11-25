import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '/utils/node.dart';
import '/utils/constants.dart';

class NodesData extends ChangeNotifier {
  List<Node> nodes = [Node.def(0), Node.def(1), Node.def(2), Node.def(3), Node.def(4)];

  void readColors(){
    for(final node in nodes){
      if(node.isConnected) node.readGlo();
    }
  }

  void replaceNode(int index, BluetoothDevice newNode){
    nodes[index].device = newNode;
    nodes[index].init();
    notifyListeners();
  }

  void clearNode(int index){
    nodes[index] = Node.def(index);
  }

  ValueNotifier<int> notifierFromMuscle(String muscle){
    print("muscle = ${muscle}");
    int index = MUSCLESITES.indexOf(muscle);
    print("index = ${index}");
    assert (index >= 0);

    Node node = (index == 4 || index == 5)? nodes[0] :      // Muscles read by Node 0
                (index > 3)? nodes[2 | index % 2]    :      // Muscles read by Node 2 | 3
                nodes[(index % 2 == 0)? 1 : 4]       ;      // Muscles read by Node 1 | 4
    print("node = ${node.id}");

    if((index < 8) && (index & 2 > 0 || index == 5)){ 
      print("musclesite = M1");
      return node.m1Notifier; // Muscle 1 in Node
    }
    else{     
      print("musclesite = M0");          
      return node.m0Notifier; // Muscle 0 in Node
    }
  }
}