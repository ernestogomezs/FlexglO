import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oscilloscope/oscilloscope.dart';

import '/models/chartsdata.dart';
import '/models/nodesdata.dart';

class ChartWidget extends StatefulWidget{
  ChartWidget(this.chart, this.onDelete, {Key? key}) : super(key: key);

  final Chart chart;
  final void Function(Chart) onDelete;

  @override
  State<ChartWidget> createState() => _ChartState();
}

class _ChartState extends State<ChartWidget>{
  late Oscilloscope scope;

  @override
  void initState() {
    widget.chart.muscleValue = Provider.of<NodesData>(context, listen: false).notifierFromMuscle(widget.chart.muscle);

    scope = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.black,
      margin: EdgeInsets.all(20.0),
      strokeWidth: 2.0,
      backgroundColor: Colors.white,
      traceColor: Colors.black,
      yAxisMax: 2050,
      yAxisMin: 0,
      dataSet: widget.chart.data,

    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildBar(){
    return Row(
      children: [
        Text(widget.chart.muscle),
        ElevatedButton(
          child: Icon(Icons.delete),
          onPressed: (){
            widget.onDelete;
          },
        )
      ],
    );
  }

  Widget buildGraph(){
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 4.0, color: Colors.grey),
          borderRadius: BorderRadius.circular(4)
        ),
        margin: const EdgeInsets.all(5),
        child: scope
      )
    );
  }

  @override
  Widget build(BuildContext context){
    return Column(
      children: <Widget>[
        buildBar(),
        buildGraph()
      ]
    );
  }
}