import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/chartsdata.dart';
import '/models/nodesdata.dart';

class ChartsTable extends StatefulWidget{
  ChartsTable(this.elapsedTime, 
              this.stopwatchRunning,
              {Key? key}) : super(key: key);

  final ValueNotifier<Duration> elapsedTime;
  final ValueNotifier<bool> stopwatchRunning;

  @override
  State<ChartsTable> createState() => _ChartsTableState();
}

class _ChartsTableState extends State<ChartsTable>{

  @override
  void initState() {
    widget.elapsedTime.addListener((){
      Provider.of<ChartsData>(context, listen: false).updateCharts();
      if(mounted){
        setState((){
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TopBar(widget.stopwatchRunning),
        Consumer<ChartsData>(
          builder: (context, chartsData, child){
            return (chartsData.charts.isNotEmpty)
              ? Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, 
                        width: 1
                      ),
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      height: 500,
                      child: SingleChildScrollView(
                        child: Consumer<ChartsData>(
                          builder: (context, chartsData, child) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: chartsData.chartWidgets
                            );     
                          }
                        )
                      )
                    )
                  )
                )
              : Container();
          }
        )
      ]
    );
  }
}

class TopBar extends StatefulWidget{
  TopBar(this.stopwatchRunning, {Key? key}) : super(key: key);

  final ValueNotifier<bool> stopwatchRunning;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar>{
  @override
  initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: Theme.of(context).textTheme.headlineMedium!.fontSize! * 1.1 + 20,
      ),
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8)
      ),
      child: OverflowBar(  
        textDirection: TextDirection.rtl,
        children: [
          DropdownButtonHideUnderline(
            child: Consumer<NodesData>(
              builder: (context, nodesData, child) {
                return DropdownButton<String>(
                  items: nodesData.availableMuscles.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  icon: nodesData.availableMuscles.isEmpty? 
                    null : Icon(Icons.add, color: Colors.grey[800]),
                  iconDisabledColor: Colors.grey,
                  isExpanded: true,
                  hint: Center(
                    child: Text(
                      nodesData.availableMuscles.isEmpty? 
                        "Connect nodes to log data" :
                        "Select muscle to record data",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[800]),
                    )
                  ),
                  onChanged: (String? choice){
                    nodesData.addMuscle(choice!);
                    Provider.of<ChartsData>(context, listen: false).addChart(choice, widget.stopwatchRunning);
                  },
                );
              }
            ),
          )
        ],
      ),
    );
  }
}