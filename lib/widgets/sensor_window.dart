import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

List<Color> COLORLIST = [
  Color.fromRGBO(0xFF, 0, 0, 1.0),
  Color.fromRGBO(0, 0xFF, 0, 1.0),
  Color.fromRGBO(0, 0, 0xFF, 1.0),
  Color.fromRGBO(0, 0xFF, 0xFF, 1.0),
  Color.fromRGBO(0xFF, 0, 0xFF, 1.0),
  Color.fromRGBO(0xFF, 0xFF, 0, 1.0),
  Color.fromRGBO(0xFF, 0xFF, 0xFF, 1.0)
];

class SensorWindowButton extends StatelessWidget{
  SensorWindowButton({Key? key, 
    required this.muscle,
    required this.muscleSite,
    required this.nodeID,
    required this.flexNotifier, 
    required this.connectionStateNotifier,
    required this.writeColorChange
  });

  final String muscle;
  final int muscleSite;
  final String nodeID;
  final ValueNotifier<int> flexNotifier;
  final ValueNotifier<bool> connectionStateNotifier;
  final Function writeColorChange;

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context){
                if(!connectionStateNotifier.value){
                  return AlertDialog(
                    title: Text('Node $nodeID for $muscle is not connected'),
                    content: Text('Make sure node $nodeID is connected in the Bluetooth menu'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => {
                          Navigator.pop(context, 'OK')
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                }
                else{
                  return SensorWindow(muscle, muscleSite, flexNotifier, writeColorChange);
                }
              }
            )
          );
        },
        child: Hero(
          tag: muscle,
          child: Material(
            color: Colors.blueGrey,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22)
            ),
            child: const Icon(
              Icons.circle,
              size: 26,
              color: Colors.white
            ),
          )
        ),
      ),
    );
  }
}

class SensorWindow extends StatefulWidget {
  SensorWindow(this.muscle, this.muscleSite, this.muscleIntensityNotify, this.writeColorChange);

  final String muscle;
  final int muscleSite;
  late ValueNotifier<int> muscleIntensityNotify;
  final Function writeColorChange;

  @override
  SensorWindowState createState() => SensorWindowState();
}

class SensorWindowState extends State<SensorWindow> {
  List<int> trace = [];
  double radians = 0.0;
  Timer? _timer;
  Color currentColor = Color.fromRGBO(0, 0xFF, 0, 1.0);

  /// method to generate wave pattern
  _generateTrace(Timer t) {
    // Read latest value
    int muscleIntensityValue = widget.muscleIntensityNotify.value;

    // Add latest read value to the growing dataset
    setState(() {
      trace.add(muscleIntensityValue);
    });
  }

  void changeColor(Color color) {
    widget.writeColorChange(color, widget.muscleSite);
    setState(() => currentColor = color);
  }

  @override
  initState() {
    super.initState();
    // create our timer to generate test values
    _timer = Timer.periodic(Duration(milliseconds: 64), _generateTrace);
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    Oscilloscope scopeOne = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.grey,
      margin: EdgeInsets.all(20.0),
      strokeWidth: 3.0,
      backgroundColor: Colors.white,
      traceColor: currentColor,
      yAxisMax: 2050,
      yAxisMin: 0,
      dataSet: trace,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.muscle),
        backgroundColor: Colors.white
      ),
      body: Hero(
        tag: widget.muscle,
        child: Column(
          children:[
            Expanded(
              child: scopeOne
            ),
            Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                children: <Widget>[
                  Text("Select a color for this muscle:"),
                  BlockPicker(
                    pickerColor: currentColor,
                    onColorChanged: changeColor,
                    availableColors: COLORLIST,
                  )
                ]
              )
            )
          ]
        )
          
      ),
    );
  }
}


