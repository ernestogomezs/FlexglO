import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/widgets/flexglow_line_chart.dart';  

import '/models/chartsdata.dart';
import '/models/nodesdata.dart';

class ChartWidget extends StatefulWidget{
  ChartWidget(this.chart, {Key? key}) : super(key: key);

  final Chart chart;

  @override
  State<ChartWidget> createState() => _ChartState();
}

class _ChartState extends State<ChartWidget>{
  late FlexGlowLineChart scope;

  @override
  void initState() {
    print("MMG");
    widget.chart.muscleValue = 
      Provider.of<NodesData>(context, listen: false).notifierFromMuscle(widget.chart.muscle);

    Provider.of<ChartsData>(context, listen: false).addListener(() {
        if(mounted){
          setState((){});
        }
      }
    );

    scope = FlexGlowLineChart(
      chart: widget.chart
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildBar(){
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.grey, width: 1)
        ),
        color: Colors.white,
      ),
      height: 50,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.chart.muscle, 
                style: TextStyle(fontWeight: FontWeight.bold)
              )
            ),
            ElevatedButton(
              child: Icon(Icons.delete),
              onPressed: (){
                Provider.of<ChartsData>(context, listen: false).removeChart(widget.chart.muscle);
                Provider.of<NodesData>(context, listen: false).removeChart(widget.chart.muscle);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildGraph(){
    return scope;
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