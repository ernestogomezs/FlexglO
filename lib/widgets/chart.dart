import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oscilloscope/oscilloscope.dart';

import '/models/nodesdata.dart';

class Chart extends StatefulWidget{
  Chart(this.muscle, this.color, {Key? key});

  final String muscle;
  final Color color;
  final List<int> data = [];

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart>{
  List<double> trace = [];
  ValueNotifier<int> value = ValueNotifier<int>(0);
  double radians = 0.0;
  Timer? _timer;

  /// method to generate a Test  Wave Pattern Sets
  /// this gives us a value between +1  & -1 for sine & cosine
  _generateTrace(Timer t) {
    // generate our  values
    var sv = sin((radians * pi));

    // Add to the growing dataset
    setState(() {
      trace.add(sv);
    });

    // adjust to recyle the radian value ( as 0 = 2Pi RADS)
    radians += 0.05;
    if (radians >= 2.0) {
      radians = 0.0;
    }
  }

  @override
  void initState() {
    value = Provider.of<NodesData>(context, listen: false).notifierFromMuscle(widget.muscle);
    _timer = Timer.periodic(Duration(milliseconds: 60), _generateTrace);
    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    Oscilloscope scope = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.black,
      margin: EdgeInsets.all(20.0),
      strokeWidth: 2.0,
      backgroundColor: Colors.white,
      traceColor: Colors.black,
      yAxisMax: 1.0,
      yAxisMin: -1.0,
      dataSet: trace,
    );

    return Expanded(
      // child: Container(
      //   margin: const EdgeInsets.all(10),
      //   decoration: BoxDecoration(
      //     color: Colors.grey,
      //     border: Border.all(
      //       width: 2,
      //       color: Colors.black
      //     ),
      //     borderRadius: BorderRadius.all(Radius.circular(5))
      //   ),
      flex: 1,
      child:  scope
    );
    // );
  }
}