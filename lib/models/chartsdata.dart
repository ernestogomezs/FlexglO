import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '/utils/constants.dart';

import '/widgets/chart_widget.dart';

class Chart{
  Chart(this.muscle, this.color, this.stopwatchRunning, {Key? key});

  final String muscle;
  final Color color;
  final ValueNotifier<bool> stopwatchRunning;
  late ValueNotifier<int> muscleValue;
  late List<int> data = [];
  late List<FlSpot> points = [];
}

class ChartsData extends ChangeNotifier {
  final List<Chart> charts = [];  
  final List<ChartWidget> chartWidgets = [];
  final Stopwatch stopwatch = Stopwatch();
  final ValueNotifier<Duration> elapsedTime = ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<bool> stopwatchRunning = ValueNotifier<bool>(false);

  late Timer timer;
  
  ChartsData(BuildContext context){
    elapsedTime.value = Duration.zero;
    timer = Timer.periodic(const Duration(milliseconds: CHART_TIMESTEP_MS), 
      (Timer timer) {
        if (stopwatch.isRunning) {
          _updateElapsedTime();
        }
      }
    );

    elapsedTime.addListener((){     
      updateCharts();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void toggleStopwatch() {
    if(!stopwatch.isRunning) {
      reset();
      stopwatch.start();
    } 
    else{
      stopwatch.stop();
    }
    _updateElapsedTime();
    stopwatchRunning.value = stopwatch.isRunning;
  }

  void reset(){
    stopwatch.reset();
    _updateElapsedTime();
    resetCharts();
  }

  void _updateElapsedTime() {
    elapsedTime.value = stopwatch.elapsed;
  }

  void addChart(String muscle) {
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

  void resetCharts(){
    if(charts.isEmpty) return;
    
    for(final chart in charts){
      chart.data.clear();
      chart.points.clear();
    }
    notifyListeners();
  }

  void removeChart(String muscle){
    int toDelete = charts.indexWhere((chart) => chart.muscle == muscle);
    if(toDelete >= 0){
      chartWidgets.removeAt(toDelete);
      charts.removeAt(toDelete);
      notifyListeners();
    }
  }
}