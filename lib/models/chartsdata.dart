import 'package:flutter/material.dart';

import '../widgets/chart.dart';

class ChartsData extends ChangeNotifier {
  List<Chart> charts = [];

  void addChart(String chart) {
    var newChart = Chart(chart, Color.fromRGBO(0, 0xFF, 0, 1.0));
    charts.add(newChart);
    notifyListeners(); // Notify listeners to rebuild any widget that listens to this data
  }

  void removeChart(){
    
  }
}