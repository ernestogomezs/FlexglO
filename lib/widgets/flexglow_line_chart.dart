import 'package:fl_chart/fl_chart.dart';
import 'package:flexglow_app/utils/constants.dart';  
import 'package:flutter/material.dart';

import '/models/chartsdata.dart';

class FlexGlowLineChart extends StatefulWidget {
  const FlexGlowLineChart({required this.chart ,super.key});

  final Chart chart;

  @override
  State<FlexGlowLineChart> createState() => _FlexGlowLineChartState();
}

class _FlexGlowLineChartState extends State<FlexGlowLineChart> {
  final points = <FlSpot>[];

  double xValue = 0;

  @override
  void initState() {
    super.initState();
    widget.chart.muscleValue.addListener((){
      if (widget.chart.stopwatchRunning.value){
        setState(() {
          points.add(FlSpot(xValue, widget.chart.muscleValue.value.toDouble()));
          xValue += CHART_TIMESTEP_MS;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return points.isNotEmpty
    ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 5),
          Text(
            'Last Recorded Intensity: ${points.last.y.toStringAsFixed(1)}',
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
                  minX: points.length > 100? points[points.length-100].x : points.first.x,
                  maxX: points.length< 100? 10000 : points.last.x,
                  lineTouchData: const LineTouchData(enabled: false),
                  clipData: const FlClipData.all(),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    line(points),
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

  LineChartBarData line(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      color: widget.chart.color,
      dotData: const FlDotData(
        show: false,
      ),
      barWidth: 2,
      isCurved: false,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}