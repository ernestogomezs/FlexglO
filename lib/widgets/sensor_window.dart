import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SensorWindowButton extends StatelessWidget{
  SensorWindowButton({Key? key, required this.muscle, required this.flexNotifier});

  final String muscle;
  final ValueNotifier<double> flexNotifier;

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context){
                return SensorWindow(muscle, flexNotifier);
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
  SensorWindow(this.muscle, this.muscleIntensityNotify);

  final String muscle;
  late ValueNotifier<double> muscleIntensityNotify;

  @override
  SensorWindowState createState() => SensorWindowState();
}

class SensorWindowState extends State<SensorWindow> {
  List<double> trace = [];
  double radians = 0.0;
  Timer? _timer;
  Color CurrentColor = Color.fromRGBO(0xFF, 0xFF, 0xFF, 1.0);
  List<Color> CurrentColors = [
    Color.fromRGBO(0xFF, 0, 0, 1.0),
    Color.fromRGBO(0, 0xFF, 0, 1.0),
    Color.fromRGBO(0, 0, 0xFF, 1.0),
    Color.fromRGBO(0, 0xFF, 0xFF, 1.0),
    Color.fromRGBO(0xFF, 0, 0xFF, 1.0),
    Color.fromRGBO(0xFF, 0xFF, 0, 1.0),
    Color.fromRGBO(0xFF, 0xFF, 0xFF, 1.0)
  ];

  /// method to generate wave pattern
  _generateTrace(Timer t) {
    // Read latest value
    double muscleIntensityValue = widget.muscleIntensityNotify.value;

    // Add latest read value to the growing dataset
    setState(() {
      trace.add(muscleIntensityValue);
    });
  }

  void changeColor(Color color) {
    setState(() => CurrentColor = color);
  }

  void changeColors(List<Color> colors) {
    setState(() => CurrentColors = colors);
  }

  @override
  initState() {
    super.initState();
    // create our timer to generate test values
    _timer = Timer.periodic(Duration(milliseconds: 10), _generateTrace);
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
      strokeWidth: 1.0,
      backgroundColor: Colors.white,
      traceColor: Colors.black,
      yAxisMax: 500.0,
      yAxisMin: -1.0,
      dataSet: trace,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
              child: MultipleChoiceBlockPicker(
                pickerColors: CurrentColors,
                onColorsChanged: changeColors,
              )
            )
          ]
        )
          
      ),
    );
  }
}


