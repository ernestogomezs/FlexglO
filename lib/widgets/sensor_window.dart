import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '/utils/node.dart';
import '/utils/constants.dart';

class SensorWindowButton extends StatefulWidget{
  SensorWindowButton({Key? key, 
    required this.muscle,
    required this.muscleSite,
    required this.node,
  }): super (key: key);

  final String muscle;
  final int muscleSite;
  final Node node;

  @override
  State<SensorWindowButton> createState() => _SensorWindowButtonState();
}
   
class _SensorWindowButtonState extends State<SensorWindowButton> {
  late Color muscleColor = widget.node.gloFromMuscle(widget.muscleSite);

  @override
  void initState() {
    widget.node.connectionStateNotifier.addListener((){
      if(widget.node.isConnected){
        muscleColor = widget.node.gloFromMuscle(widget.muscleSite);
      }
      else{
        muscleColor = Colors.black;
      }
      if(mounted){
        setState((){});
      }
    });
    widget.node.gloBytesNotifier.addListener((){
      muscleColor = widget.node.gloFromMuscle(widget.muscleSite);
      if(mounted){
        setState((){});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 400),
        closedBuilder: (context, openContainer){
          return GestureDetector(
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
                openContainer();
              }
            },
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
          );
        },
        openBuilder: (context, closeContainer){
          return SensorWindow(widget.muscle, widget.muscleSite, widget.node);
        }
      )
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

  _generateTrace(Timer t) {
    int muscleIntensityValue = (widget.muscleSite == 0)? 
      widget.node.m0Notifier.value : 
      widget.node.m1Notifier.value;

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
    widget.node.readGlo();
    _timer = Timer.periodic(Duration(milliseconds: 64), _generateTrace);
    currentColor = Color.fromRGBO(widget.node.gloBytesNotifier.value[0 + widget.muscleSite * 3], 
                                  widget.node.gloBytesNotifier.value[1 + widget.muscleSite * 3], 
                                  widget.node.gloBytesNotifier.value[2 + widget.muscleSite * 3], 
                                  1.0);
    super.initState();
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
      yAxisColor: Colors.black,
      margin: EdgeInsets.all(20.0),
      strokeWidth: 2.0,
      backgroundColor: Colors.white,
      traceColor: (currentColor == Colors.white)? Colors.black : currentColor,
      yAxisMax: 2050,
      yAxisMin: 0,
      dataSet: trace,
    );

    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(widget.muscle),
        backgroundColor: Colors.white
      ),
      body: Column(
        children:[
          Expanded(
            flex: 1,
            child: scopeOne
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const 
                    Text("Select a color for this muscle:")
                  ),
                  FittedBox(
                    child: BlockPicker(
                      pickerColor: currentColor,
                      onColorChanged: changeColor,
                      availableColors: COLORLIST,
                      layoutBuilder: pickerLayoutBuilder,
                    ),
                  )
                ]
              )
            ),
          )
        ]
      ),
    );
  }
}

Widget pickerLayoutBuilder(BuildContext context, List<Color> colors, PickerItem child) {
  Orientation orientation = MediaQuery.of(context).orientation;
  int portraitCrossAxisCount = 4;
  int landscapeCrossAxisCount = 5;
  return SizedBox(
    width: 300,
    height: orientation == Orientation.portrait ? 160 : 240,
    child: GridView.count(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: orientation == Orientation.portrait ? portraitCrossAxisCount : landscapeCrossAxisCount,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      children: [for (Color color in colors) child(color)],
    ),
  );
}