import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '/utils/node.dart';
import '/utils/constants.dart';
import '/widgets/flexglow_line_chart.dart';

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
          return SensorWindow(widget.muscle, widget.muscleSite, widget.node, closeContainer);
        }
      )
    );
  }
}

class SensorWindow extends StatefulWidget {
  SensorWindow(this.muscle, 
               this.muscleSite, 
               this.node,
               this.closeWindow);

  final String muscle;
  final int muscleSite;
  final Node node;
  final VoidCallback closeWindow;

  @override
  State<SensorWindow> createState() => _SensorWindowState();
}

class _SensorWindowState extends State<SensorWindow> {
  // Timer? _timer;
  // List<int> trace = [];

  List<FlSpot> trace = [FlSpot(0,0)];
  double msLenght = 0;

  bool rmsOn = true;
  List<FlSpot> rmsTrace = [FlSpot(0,0)];
  int rmsCount = 0;
  double rmsVal = 0;

  late Color currentColor;
  late ValueNotifier<int> muscleIntensityNotifier;

  @override
  initState() {
    muscleIntensityNotifier = (widget.muscleSite == 0)? 
      widget.node.m0Notifier : 
      widget.node.m1Notifier;

    widget.node.connectionStateNotifier.addListener((){
      if (!widget.node.connectionStateNotifier.value) {
        if(mounted)
        {
        widget.closeWindow();
        }        
      }
    });
    //_timer = Timer.periodic(Duration(milliseconds: CHART_TIMESTEP_MS), _generateTrace);

    muscleIntensityNotifier.addListener(() => _generateTrace());
    
    currentColor = Color.fromRGBO(
      widget.node.gloBytesNotifier.value[0 + widget.muscleSite * 3], 
      widget.node.gloBytesNotifier.value[1 + widget.muscleSite * 3], 
      widget.node.gloBytesNotifier.value[2 + widget.muscleSite * 3], 
      1.0
    );
    super.initState();
  }

  @override
  void dispose() {
    //_timer.dispose();
    super.dispose();
  }

  void _generateTrace(){// Timer t) {
    msLenght += CHART_TIMESTEP_MS;
    // trace.add(muscleIntensityNotifier.value);
    trace.add(FlSpot(msLenght, muscleIntensityNotifier.value.toDouble()));

    rmsVal += muscleIntensityNotifier.value.toDouble() * muscleIntensityNotifier.value.toDouble();
    if(rmsCount++ > RMSAMTVALS){
      rmsTrace.add(FlSpot(msLenght, sqrt(rmsVal/RMSAMTVALS)));
      rmsCount = 0;
      rmsVal = 0;
    }
    
    if(mounted){
      setState((){});
    }
  }

  void _changeColor(Color color) {
    widget.node.writeGloColor(color, widget.muscleSite);
    setState(() => currentColor = color);
  }

  @override
  Widget build(BuildContext context){
    Widget scope = 
    // Oscilloscope(
    //   showYAxis: true,
    //   yAxisColor: Colors.black,
    //   margin: EdgeInsets.all(20.0),
    //   strokeWidth: 2.0,
    //   backgroundColor: Colors.white,
    //   traceColor: (currentColor == Colors.white)? Colors.black : currentColor,
    //   yAxisMax: 2050,
    //   yAxisMin: 0,
    //   dataSet: trace,
    // );
    
    trace.isNotEmpty
    ? Container(
      color: Colors.white,
      child: AspectRatio(
        aspectRatio: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return LineChart(
                LineChartData(
                  minY: -1,
                  maxY: 2050,
                  minX: trace.length > 100? 
                    trace[trace.length - 100].x : 
                    trace.first.x,
                  maxX: trace.length < 100? 
                    CHART_TIMESTEP_MS * 100 : 
                    trace.last.x,
                  lineTouchData: const LineTouchData(enabled: false),
                  clipData: const FlClipData.all(),
                  gridData: const FlGridData(
                    show: true,
                    horizontalInterval: 500,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    line(trace, (currentColor == Colors.white)? Colors.black : currentColor,),
                    if (rmsOn) line(rmsTrace, Colors.blue, true, true)
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameSize: 22,
                      axisNameWidget: axisTitleWidget("Intensity (0-2048)", Axis.vertical ,constraints.maxWidth), 
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) =>
                              leftTitleWidgets(value, meta, constraints.maxWidth),
                      )
                    ),
                    bottomTitles: AxisTitles(
                      axisNameSize: 22,
                      axisNameWidget: axisTitleWidget("Time (s)", Axis.horizontal ,constraints.maxWidth), 
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) =>
                              bottomTitleWidgets(value, meta, constraints.maxWidth),
                      )
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
              
                      )
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
              
                      )
                    )
                  ),
                ),
              );
            }
          ),
        ),
      ),
    ) : Container();

    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(widget.muscle),
        backgroundColor: Colors.white
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Expanded(
            child: scope
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const 
                    Text("Select a color for this muscle:")
                  ),
                  FittedBox(
                    child: BlockPicker(
                      pickerColor: currentColor,
                      onColorChanged: _changeColor,
                      availableColors: COLORLIST,
                      layoutBuilder: pickerLayoutBuilder,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Text(
                        "RMS"
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.remove_red_eye
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: rmsOn,
                        activeColor: Colors.blue,
                        onChanged: (bool value) {
                          setState(() {
                            rmsOn = value;
                          });
                        },
                      )
                    ],
                  ),
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