import 'package:flutter/material.dart';

class Chart{
  Chart(this.muscle, this.color, {Key? key});

  final String muscle;
  final Color color;
  late ValueNotifier<int> muscleValue;
  late List<int> data = [];
}

class ChartsData extends ChangeNotifier {
  List<Chart> charts = [];
  late void Function() myMethod;
  
  Chart addChart(String muscle) {
    charts.add(Chart(muscle, Color.fromRGBO(0, 0xFF, 0, 1.0)));
    notifyListeners(); // Notify listeners to rebuild any widget that listens to this data
    return charts.last;
  }

  void updateCharts(){
    for(final chart in charts){
      chart.data.add(chart.muscleValue.value);
    }
  }

  void removeChart(){
    
  }
}