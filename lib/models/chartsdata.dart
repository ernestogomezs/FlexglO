import 'package:flexglow_app/utils/constants.dart';
import 'package:flexglow_app/widgets/chart_widget.dart';
import 'package:flutter/material.dart';

class Chart{
  Chart(this.muscle, this.color, this.stopwatchRunning, {Key? key});

  final String muscle;
  final Color color;
  final ValueNotifier<bool> stopwatchRunning;
  late ValueNotifier<int> muscleValue;
  late List<int> data = [];
}

class ChartsData extends ChangeNotifier {
  List<Chart> charts = [];  
  List<ChartWidget> chartWidgets = [];
  
  ChartsData(BuildContext context){
  }

  void addChart(String muscle, ValueNotifier<bool> stopwatchRunning) {
    charts.add(Chart(muscle, DEFAULTCOLOR, stopwatchRunning));
    chartWidgets.add(ChartWidget(charts.last));
    notifyListeners();
  }

  void updateCharts(){
    for(final chart in charts){
      chart.data.add(chart.muscleValue.value);
    }
    notifyListeners();
  }

  void clearCharts(){
    for(final chart in charts){
      chart.data.clear();
    }
    notifyListeners();
  }

  void removeChart(String muscle){
    int toDelete = charts.indexWhere((chart) => chart.muscle == muscle);
    if(toDelete > 0){
      chartWidgets.removeAt(toDelete);
      charts.removeAt(toDelete);
      notifyListeners();
    }
  }
}