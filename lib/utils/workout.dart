import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/utils/constants.dart';
import '/models/nodesdata.dart';

const int MUSCLECOUNT = 5;
const int WINDOWSIZE = 8;
const int ACTIVEVAL = 1024;

class Workout{
  int currentRow = 0;
  List<List<int>> table = List.filled(WINDOWSIZE, List<int>.filled(MUSCLECOUNT, 0));
  List<ValueNotifier<int>> muscleRow = List.filled(MUSCLECOUNT, ValueNotifier<int>(0)); 

  Workout(BuildContext context){
    // List of notifiers that change based on the max value read between two other notifiers
    NodesData nodesData = Provider.of<NodesData>(context, listen: false);
    
    for(int muscleGroup = 0; muscleGroup < MUSCLECOUNT; ++muscleGroup){
      var notifierL = nodesData.notifierFromMuscle(MUSCLESITES[(muscleGroup * 2)]); 
      var notifierR = nodesData.notifierFromMuscle(MUSCLESITES[(muscleGroup * 2) + 1]);

      notifierL.addListener(() => maxMuscle(notifierL, notifierR, muscleGroup));
      notifierR.addListener(() => maxMuscle(notifierL, notifierR, muscleGroup));

      muscleRow[muscleGroup].addListener(() => insertChange);
    }
  }

  void maxMuscle(ValueNotifier<int> leftMuscle, ValueNotifier<int> rightMuscle, int muscleGroup){   
    muscleRow[muscleGroup].value = ((max(leftMuscle.value, rightMuscle.value) > ACTIVEVAL)? 0 : 1);
  }

  void insertChange(){
    bool anyChanged = ;

    if(anyChanged){
      table[currentRow] = muscleRow.map((muscle) => muscle.value).toList();
      currentRow = ++currentRow % WINDOWSIZE;
    }
  }

  List<int> detectChange(){

  }

  void clearTable(){
    table = List.filled(5, List<int>.filled(WINDOWSIZE, 0));
  }

  void dispose(){
    muscleRow.map((muscle) => muscle.dispose());
  }
}