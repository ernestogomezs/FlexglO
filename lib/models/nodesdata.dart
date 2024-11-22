import 'package:flutter/material.dart';

import '/utils/node.dart';
import '/utils/constants.dart';

class NodesData extends ChangeNotifier {
  List<Node> nodes = [Node.def(0), Node.def(1), Node.def(2), Node.def(3), Node.def(4)];

  void replaceNode(index, newNode){
    nodes[index] = newNode;
    notifyListeners();
  }

  ValueNotifier<int> notifierFromMuscle(String muscle){
    int index = MUSCLESITES.indexOf(muscle);
    assert (index >= 0);

    Node node = (index == 4 || index == 5)? nodes[0] :      // Muscles read by Node 0
                (index > 3)? nodes[2 | index % 2]    :      // Muscles read by Node 2 | 3
                nodes[(index % 2 == 0)? 1 : 4]       ;      // Muscles read by Node 1 | 4

    if((index & 8 == 0) && (index & 2 == 1 || index == 5)){ 
      return node.m1Notifier; // Muscle 1 in Node
    }
    else{                                                   
      return node.m0Notifier; // Muscle 0 in Node
    }
  }
}