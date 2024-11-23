import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../utils/node.dart';
import '/utils/constants.dart';

class SensorWindowButton extends StatefulWidget{
  SensorWindowButton({Key? key, 
    required this.muscle,
    required this.muscleSite,
    required this.node
  });

  final String muscle;
  final int muscleSite;
  final Node node;

  @override
  State<SensorWindowButton> createState() => _SensorWindowButtonState();
}
   
class _SensorWindowButtonState extends State<SensorWindowButton> {
  Color muscleColor = DEFAULTCOLOR;

  @override
  void initState() {
    widget.node.connectionStateNotifier.addListener((){
      setState((){
        if(widget.node.connectionStateNotifier.value){
          widget.node.gloFromMuscle(widget.muscleSite).then((value) => muscleColor = value);
        }
        else{
          muscleColor = Colors.black;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GestureDetector(
        onTap: () {
          if(!widget.node.connectionStateNotifier.value){
            showDialog(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Text('Node ${widget.node.id} for ${widget.muscle} is not connected'),
                  content: Text('Make sure node ${widget.node.id} is connected in the Bluetooth menu'),
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
                return SensorWindow(widget.muscle, widget.muscleSite, widget.node);
              }
            ));
          }
        },
        child: Hero(
          tag: widget.muscle,
          child: Material(
            color: Colors.white,
            elevation: 2,
            shape: CircleBorder(),
            child:  ValueListenableBuilder(
              valueListenable: (widget.muscleSite == 0)? widget.node.m0Notifier : widget.node.m1Notifier,
              builder: (context, muscleValue, child){
                return Icon(
                  Icons.circle,
                  size: 26,
                  color: (widget.node.connectionStateNotifier.value)?
                         Color.fromRGBO(muscleColor.red, muscleColor.green, muscleColor.blue, muscleValue/2048.0) :
                         Colors.black
                );
              }
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
  late Color currentColor;

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
    widget.node.readGlo();
    currentColor = Color.fromRGBO(widget.node.gloBytesNotifier.value[0 + widget.muscleSite * 3], 
                                  widget.node.gloBytesNotifier.value[1 + widget.muscleSite * 3], 
                                  widget.node.gloBytesNotifier.value[2 + widget.muscleSite * 3], 
                                  1.0);
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


