import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '/utils/constants.dart';
import '/models/nodesdata.dart';

class Workout extends ChangeNotifier{
  ValueNotifier<List<List<int>>> table = 
    ValueNotifier<List<List<int>>>(List.filled(WINDOWSIZE, List<int>.filled(MUSCLECOUNT, 0)));
  ListNotifier functors =
    ListNotifier(List.filled(MUSCLECOUNT, MaxValueNotifier.def(0)));

  int currentRow = 0;

  WorkoutCounter workoutCounter = WorkoutCounter();
  ValueNotifier<List<List<int>>> lastRep = 
    ValueNotifier<List<List<int>>>([]);
  ValueNotifier<List<Pair>> rankings = 
    ValueNotifier<List<Pair>>([
      Pair(MuscleGroups.Biceps,    0),
      Pair(MuscleGroups.Triceps,   0),
      Pair(MuscleGroups.Chest,     0),
      Pair(MuscleGroups.Lats,      0),
      Pair(MuscleGroups.Shoulders, 0)
    ]);

  Workout(BuildContext context){

    // List of notifiers that change based on the max value read between two other notifiers
    NodesData nodesData = Provider.of<NodesData>(context, listen: false);
    
    for(int muscleGroup = 0; muscleGroup < MUSCLECOUNT; muscleGroup++){
      int mL = muscleGroup * 2;
      int mR = muscleGroup * 2 + 1;
      var notifierL = nodesData.notifierFromMuscle(MUSCLESITES[mL]); 
      var notifierR = nodesData.notifierFromMuscle(MUSCLESITES[mR]);

      functors.insert(MaxValueNotifier(0, notifierL, notifierR, muscleGroup), muscleGroup);

      nodesData.notifierFromMuscle(MUSCLESITES[mL]).addListener((){
        functors.value[muscleGroup].getMaxMuscle();
      });
      nodesData.notifierFromMuscle(MUSCLESITES[mR]).addListener((){
        functors.value[muscleGroup].getMaxMuscle();
      });
    }

    functors.addListener(() => insertChange());
  }

  void insertChange(){
    table.value[currentRow] = functors.value.map((muscle) => muscle.value).toList();
    table.notifyListeners();
    if(listEquals<int>(table.value[currentRow], List<int>.filled(MUSCLECOUNT, 0))){
      lastRep.value = table.value.sublist(0, currentRow);
      rankings.value = workoutCounter.analyze(lastRep.value);
      clearTable();
      currentRow = 0;
    }
    else{
      currentRow = (currentRow + 1) % WINDOWSIZE;
      if(currentRow == 0){
        lastRep.value = table.value;
        rankings.value = workoutCounter.analyze(table.value);
        clearTable();
      }
    }
  }

  void clearTable(){
    table.value = List.filled(WINDOWSIZE, List<int>.filled(MUSCLECOUNT, 0));
  }

  @override
  void dispose(){
    functors.value.map((muscle) => muscle.dispose());
    functors.dispose();
    table.dispose();
    super.dispose();
  }
}

class MaxValueNotifier extends ValueNotifier<int>{
  ValueNotifier<int> leftMuscle = ValueNotifier<int>(0);
  ValueNotifier<int> rightMuscle = ValueNotifier<int>(0); 
  int index = 0;
  //ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  MaxValueNotifier.def(int initialValue) : super(initialValue);
  MaxValueNotifier(int initialValue, this.leftMuscle, this.rightMuscle, this.index)//, this.isConnected) 
                  : super(initialValue);

  void getMaxMuscle(){   
    value = (max(leftMuscle.value, rightMuscle.value) > ACTIVEVAL)? 1 : 0;
  }
}

class ListNotifier extends ValueNotifier<List<MaxValueNotifier>> {
  ListNotifier(List<MaxValueNotifier> initialList) : super(initialList);

  void insert(MaxValueNotifier notifier, int index){
    value[index] = notifier;
    notifier.addListener(() => notifyListeners());
  }
}

class WorkoutCounter {
  List<ValueNotifier<int>> counter = 
    <ValueNotifier<int>>[ValueNotifier<int>(0), ValueNotifier<int>(0), ValueNotifier<int>(0)];

  WorkoutCounter();

  void reset(){
    for(int i = 0; i < AMT_EXERCISES; ++i){
      counter[i].value = 0;
    }   
  }

  List<Pair> analyze(List<List<int>> originalRep){
    // Turn rows into columns and viceversa to analyze counts
    List<List<int>> rep = transpose(originalRep);
    
    // Sort analyzed counts to figure out the exercise being done
    List<int> sums = List<int>.filled(MUSCLECOUNT, 0);
    List<Pair> rankings = [Pair.empty(), Pair.empty(), Pair.empty(), Pair.empty(), Pair.empty()];
    for (int i = 0; i < MUSCLECOUNT; ++i){
      rankings[i].muscleGroup = MuscleGroups.values[i];
      rankings[i].sum = rep[i].reduce((left, right) => left + right);
      sums[i] = rankings[i].sum;
    }
    insertionSort(rankings);

    // Find the muscle that was active the most, and determine the exercise 
    if(rankings.last.muscleGroup == MuscleGroups.Chest){
      if(sums[MuscleGroups.Triceps.index] > 3){
        counter[Exercises.Pushups.index].value++;
      }
    }
    else if(rankings.last.muscleGroup == MuscleGroups.Lats){
      counter[Exercises.Pullups.index].value++;
    }
    else if(rankings.last.muscleGroup == MuscleGroups.Biceps){
      counter[Exercises.Curls.index].value++;
    }
   return rankings;
  } 

  List<List<int>> transpose(List<List<int>> matrix) {
    final res = <List<int>>[];
    for (int i = 0; i < matrix[0].length; ++i) {
      final r = <int>[];
      for (int j = 0; j < matrix.length; ++j) {  
        r.add(matrix[j][i]);
      }
      res.add(r);
    }

    return res;
  }
}

class Pair{
  MuscleGroups muscleGroup;
  int sum;

  Pair.empty():
    muscleGroup = MuscleGroups.Biceps,
    sum = 0;

  Pair(this.muscleGroup, this.sum);

  @override
  String toString(){
    return "muscleGroup = ${muscleGroup.toString()}, sum = $sum";
  }
}

// Greater number goes to first place
void insertionSort(List<Pair> arr) {
  int n = arr.length;
  for (int i = 1; i < n; i++) {
    Pair key = arr[i];
    int j = i - 1;

    while (j >= 0 &&  key.sum > arr[j].sum) {
      arr[j + 1] = arr[j];
      j = j - 1;
    }
    arr[j + 1] = key;
  }
}