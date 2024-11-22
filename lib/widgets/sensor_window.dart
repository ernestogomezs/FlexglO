import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../utils/node.dart';

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
    required this.node
  });

  final String muscle;
  final int muscleSite;
  final Node node;

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GestureDetector(
        onTap: () {
          if(!node.connectionStateNotifier.value){
            showDialog(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Text('Node ${node.id} for $muscle is not connected'),
                  content: Text('Make sure node ${node.id} is connected in the Bluetooth menu'),
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
            );
          }
          else{
            Navigator.push(context, MaterialPageRoute(
              builder: (context){
                return SensorWindow(muscle, muscleSite, node);
              }
            ));
          }
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
              color: Colors.white //Change to listener builder with glo bytes corresponding to muscleSite 
            ),
          )
        ),
      ),
    );
  }
}

class SensorWindow extends StatefulWidget {
  SensorWindow(this.muscle, 
               this.muscleSite, 
               this.node);

  final String muscle;
  final int muscleSite;
  final Node node;

  @override
  State<SensorWindow> createState() => _SensorWindowState();
}

class _SensorWindowState extends State<SensorWindow> {
  List<int> trace = [];
  double radians = 0.0;
  Timer? _timer;
  Color currentColor = Color.fromRGBO(0, 0xFF, 0, 1.0);

  /// method to generate wave pattern
  _generateTrace(Timer t) {
    // Read latest value
    int muscleIntensityValue = (widget.muscleSite == 0)? 
      widget.node.m0Notifier.value : 
      widget.node.m1Notifier.value;

    // Add latest read value to the growing dataset
    setState(() {
      trace.add(muscleIntensityValue);
    });
  }

  void changeColor(Color color) {
    widget.node.writeGloColor(color, widget.muscleSite);
    setState(() => currentColor = color);
  }

  @override
  initState() {
    super.initState();
    // create our timer to generate test values
    _timer = Timer.periodic(Duration(milliseconds: 64), _generateTrace);
    // widget.node.readGlo();
    // currentColor = Color.fromRGBO(widget.node.gloBytesNotifier.value[0 + widget.muscleSite * 3], 
    //                               widget.node.gloBytesNotifier.value[1 + widget.muscleSite * 3], 
    //                               widget.node.gloBytesNotifier.value[2 + widget.muscleSite * 3], 
    //                               1.0);

    currentColor = Color.fromRGBO(0, 0xff, 0, 1.0);
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


