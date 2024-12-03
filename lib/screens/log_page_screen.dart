import 'dart:async';
import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:provider/provider.dart';

import '/models/chartsdata.dart';

import '/utils/constants.dart';

import '/widgets/log_stopwatch.dart';
import '/widgets/charts_table.dart';

class LogPageScreen extends StatefulWidget{
  const LogPageScreen({Key? key}) : super(key: key);

  @override
  State<LogPageScreen> createState() => _LogPageState();
}

class _LogPageState extends State<LogPageScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  late ValueNotifier<Duration> _elapsedTime = ValueNotifier<Duration>(Duration.zero);
  late Timer _timer;
  late ValueNotifier<bool> _stopwatchRunning = ValueNotifier<bool>(false);

  late String filename = '';

  @override
  initState(){
    _elapsedTime.value = Duration.zero;
    _timer = Timer.periodic(const Duration(milliseconds: CHART_TIMESTEP_MS), (Timer timer) {
      setState(() {
        if (_stopwatch.isRunning) {
          _updateElapsedTime();
        }
      });
    });

    super.initState();
  }

  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _updateElapsedTime();
    } else {
      _stopwatch.stop();
    }
    _stopwatchRunning.value = _stopwatch.isRunning;
  }
  
  void _resetStopwatch() {
    _stopwatch.reset();
    _updateElapsedTime();
    _stopwatchRunning.value = _stopwatch.isRunning;
    Provider.of<ChartsData>(context, listen: false).clearCharts();
  }

  void _updateElapsedTime() {
    setState(() {
      _elapsedTime.value = _stopwatch.elapsed;
    });
  }

  Future<bool?> _raiseFilenameDialog() async{
    var nowTime = DateTime.now();
    String str = 'Session_from_${nowTime.month}-${nowTime.day}-${nowTime.year}';

    return showDialog<bool>(
      context: context,
      builder:(BuildContext context) { 
        return AlertDialog(
          title: const Text('Download File'),
          actions: <Widget>[
            TextFormField(
              controller: TextEditingController(text: str),
              decoration: const InputDecoration(
                icon: Icon(Icons.file_copy),
                labelText: 'Filename',
              )
            ),
            TextButton(
              onPressed: () => {
                Navigator.pop(context, true)
              },
              child: const Text('Save File'),
            ),
          ],
        );
      }
    );
  }

  String formatFile(){
    var chartsdata = Provider.of<ChartsData>(context, listen: false);
    int numSteps = _elapsedTime.value.inMilliseconds~/CHART_TIMESTEP_MS;
    List<List<dynamic>> listofLists = [];

    List<dynamic> header = ['Time'];
    for(double i = 0; i < numSteps; i = i + 0.001){
      header.add(i);
    }
    listofLists.add(header);

    for(int i = 0; i < chartsdata.charts.length; i++){
      listofLists.add(<dynamic>[chartsdata.charts[i].muscle, ...chartsdata.charts[i].data]);
    }

    String csv = const ListToCsvConverter().convert(listofLists);

    return csv;
  } 

  void _download() async{
    var raisedResult = await _raiseFilenameDialog();

    if (raisedResult == null) return;

    var file = formatFile();

    final result = await Share.shareXFiles([XFile(filename)]);

    if (result.status == ShareResultStatus.success) {
      print('Thank you for sharing the picture!');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ChartsTable(
          _elapsedTime,
          _stopwatchRunning,
        ),
        const SizedBox(height: 20.0),
        LogStopwatch(
          _elapsedTime, 
          _stopwatchRunning,
          _startStopwatch, 
          _resetStopwatch, 
          _download, ),
        const SizedBox(height: 60.0),
      ],
    );
  }
}