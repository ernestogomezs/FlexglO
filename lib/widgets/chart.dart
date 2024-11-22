import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oscilloscope/oscilloscope.dart';

import '/models/nodesdata.dart';
import '/models/chartsdata.dart';

class ChartWidget extends StatefulWidget{
  ChartWidget(this.chart, {Key? key}) : super(key: key);

  final Chart chart;

  @override
  State<ChartWidget> createState() => _ChartState();
}

class _ChartState extends State<ChartWidget>{
  ValueNotifier<int> muscleValue = ValueNotifier<int>(0);
  late Oscilloscope scope;

  @override
  void initState() {
    muscleValue = Provider.of<NodesData>(context, listen: false).notifierFromMuscle(widget.chart.muscle);

    scope = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.black,
      margin: EdgeInsets.all(20.0),
      strokeWidth: 2.0,
      backgroundColor: Colors.white,
      traceColor: Colors.black,
      yAxisMax: 1.0,
      yAxisMin: -1.0,
      dataSet: widget.chart.data,
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Expanded(
      flex: 1,
      child: scope
    );
  }

  void addValue(){
    widget.chart.data.add(muscleValue.value);
  }
}