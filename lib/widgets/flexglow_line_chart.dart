import 'dart:math';

import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';

import '/models/chartsdata.dart';
import '/utils/constants.dart';  

class FlexGlowLineChart extends StatefulWidget {
  const FlexGlowLineChart({required this.chart ,super.key});

  final Chart chart;

  @override
  State<FlexGlowLineChart> createState() => _FlexGlowLineChartState();
}

class _FlexGlowLineChartState extends State<FlexGlowLineChart> {
  double xValue = 0;

  @override
  void initState() {
    super.initState();
    widget.chart.muscleValue.addListener((){
      if(widget.chart.stopwatchRunning.value){        
        widget.chart.points.add(FlSpot(xValue, widget.chart.muscleValue.value.toDouble()));
        xValue += CHART_TIMESTEP_MS;
      } 
      if(mounted){        
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.chart.points.isNotEmpty
    ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 5),
          Text(
            'Last Recorded Intensity: ${widget.chart.points.last.y.toStringAsFixed(1)}',
            textAlign: TextAlign.left,
            style: TextStyle( 
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          AspectRatio(
            aspectRatio: 3,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: LineChart(
                LineChartData(
                  minY: -1,
                  maxY: 2050,
                  minX: widget.chart.points.length > 100? 
                    widget.chart.points[widget.chart.points.length-100].x : 
                    widget.chart.points.first.x,
                  maxX: widget.chart.points.length < 100? 
                    CHART_TIMESTEP_MS*100 : 
                    widget.chart.points.last.x,
                  lineTouchData: const LineTouchData(enabled: false),
                  clipData: const FlClipData.all(),
                  gridData: const FlGridData(
                    show: true,
                    horizontalInterval: 500,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    line(widget.chart.points, widget.chart.color),
                  ],
                  titlesData: const FlTitlesData(
                    show: false,
                  ),
                ),
              ),
            ),
          )
        ],
      )
    : Container();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

LineChartBarData line(List<FlSpot> points, Color color, [bool showDots = false, bool dashed = false]) {
  return LineChartBarData(
    spots: points,
    color: color,
    dotData: FlDotData(
      show: showDots,
    ),
    dashArray: dashed? List.filled(RMSAMTVALS, 1) : null,
    barWidth: 2,
    isCurved: false,
  );
}

Widget axisTitleWidget(String value, Axis direction, double chartWidth) {
  final style = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: min(18, 18 * chartWidth / 300),
  );
  return Text(
    value,
    style: style,
  );
}

Widget leftTitleWidgets(double value, TitleMeta meta, double chartWidth) {
  final style = TextStyle(
    color: Colors.black,
    fontSize: 12,
  );
  if(0 <= value && value < 2050){
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text('${value.toInt()}', style: style),
    );
  }
  else {
    return Container();
  }
}

Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
  if (value % 1 != 0) {
    return Container();
  }
  final style = TextStyle(
    color: Colors.black,
    fontSize: 12,
  );
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 16,
    child: Text("${(value~/1000)}", style: style),
  );
}