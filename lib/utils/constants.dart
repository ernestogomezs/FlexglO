import 'package:flutter/material.dart';

// **Number explanations:**
// Center node is node 0
// Muscle sites are numbered up to down, left to right
// Other nodes are 1-4, left to right
// example: left arm node is node 1, right arm is node 4
//
// Muscle sites are numbered up to down and left to right 
// on the guy flexing, heart is the only muscle site with #2
// example: bicep is muscle 0, tricep is muscle 1
const List<String> MUSCLESITES = [
  "Left Bicep Brachii",       // Node 1, Muscle 0
  "Right Bicep Brachii",      // Node 4, Muscle 0
  "Left Tricep Brachii",      // Node 1, Muscle 1
  "Right Tricep Brachii",     // Node 4, Muscle 1
  "Left Pectoralis Major",    // Node 0, Muscle 0
  "Right Pectoralis Major",   // Node 0, Muscle 1
  "Left Latissimus Dorsi",    // Node 2, Muscle 1
  "Right Latissimus Dorsi",   // Node 3, Muscle 1
  "Left Deltoid (Shoulder)",  // Node 2, Muscle 0
  "Right Deltoid (Shoulder)", // Node 3, Muscle 0
];

const List<Color> COLORLIST = [
  Color.fromRGBO(0xFF, 0, 0, 1.0),
  Color.fromRGBO(0, 0xFF, 0, 1.0),
  Color.fromRGBO(0, 0, 0xFF, 1.0),
  Color.fromRGBO(0, 0xFF, 0xFF, 1.0),
  Color.fromRGBO(0xFF, 0, 0xFF, 1.0),
  Color.fromRGBO(0xFF, 0xFF, 0, 1.0),
  Color.fromRGBO(0xFF, 0xFF, 0xFF, 1.0)
];

const Color DEFAULTCOLOR = Color.fromRGBO(0, 0xFF, 0, 1.0);
const List<int> DEFAULT_GLO = [0, 0xFF, 0, 0, 0xFF, 0, 0, 0];

const String DEFAULT_ID = "00000000-0000-0000-0000-000000000000";

const int MUSCLECOUNT = 5;
const int WINDOWSIZE = 16;
const int ACTIVEVAL = 500;
const int AMT_EXERCISES = 3;

enum MuscleGroups{
  Biceps,
  Triceps,
  Chest,
  Lats,
  Shoulders;

  @override
  String toString(){
    return super.toString().substring(super.toString().indexOf('.')+1);
  }
}

enum Exercises{
  Pushups,
  Pullups,
  Curls;

  @override
  String toString(){
    return super.toString().substring(super.toString().indexOf('.')+1);
  }
}