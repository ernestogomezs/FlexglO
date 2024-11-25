import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/chartsdata.dart';
import '/utils/constants.dart';
import '/widgets/chart_widget.dart';

class ChartsTable extends StatefulWidget{
  ChartsTable(this.elapsedTime, {Key? key}) : super(key: key);

  final ValueNotifier<Duration> elapsedTime;

  @override
  State<ChartsTable> createState() => _ChartsTableState();
}

class _ChartsTableState extends State<ChartsTable>{
  List<String> availableMuscles = MUSCLESITES;
  List<double> timeList = [];
  List<ChartWidget> chartsWidgets = [];

  void _addNewChart(Chart chart){
    chartsWidgets.add(ChartWidget(chart, _deleteChart));
  }

  void _deleteChart(Chart chart){
    chartsWidgets.remove(chart);
  }

  @override
  void initState() {
    widget.elapsedTime.addListener((){
        timeList.add(widget.elapsedTime.value.inMilliseconds/1000);
        Provider.of<ChartsData>(context, listen: false).updateCharts();
      }
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TopBar(_addNewChart),
        SizedBox(
          height: 500,
          child: Consumer<ChartsData>(
            builder: (context, chartsData, child) {
              return Column(
                children: chartsWidgets
              );
            }
          ),
        ),
      ]
    );
  }
}

class TopBar extends StatefulWidget{
  TopBar(this.onSelected, {Key? key}) : super(key: key);

  final void Function(Chart) onSelected;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar>{
  List<String> availableMuscles = List<String>.from(MUSCLESITES);
  
  @override
  initState(){
    super.initState();
  }

  void addPlot(String selectedMuscle) {
    if (availableMuscles.contains(selectedMuscle)) {
      var chart = Provider.of<ChartsData>(context, listen: false).addChart(selectedMuscle);
      widget.onSelected(chart);
      availableMuscles.remove(selectedMuscle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: Theme.of(context).textTheme.headlineMedium!.fontSize! * 1.1+50,
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
          DropdownButton<String>(
            items: availableMuscles.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            icon: Icon(
              Icons.add,
              color: Colors.grey[800]
            ),
            isExpanded: true,
            hint: Center(
              child: Text(
                "Select a muscle to record data",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[800]),
              )
            ),
            onChanged: (String? choice){
              addPlot(choice!);
            },
          )
        ],
      ),
    );
  }
}