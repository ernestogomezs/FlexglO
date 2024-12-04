import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/chartsdata.dart';

class LogStopwatch extends StatefulWidget{
  LogStopwatch(this.elapsedTime,
               this.stopwatchRunning,
               this.toggleStopwatch, 
               this.download,
               this.clear,
               {Key? key}) : super(key: key);

  final ValueNotifier<Duration> elapsedTime;
  final ValueNotifier<bool> stopwatchRunning;
  final VoidCallback? toggleStopwatch;
  final VoidCallback? download;
  final VoidCallback? clear;

  @override
  State<LogStopwatch> createState() => _LogStopwatchState();
}

class _LogStopwatchState extends State<LogStopwatch>{
  // Format a Duration into a string (MM:SS.SS)
  String _formatElapsedTime(Duration time) {
    return '${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(time.inMilliseconds % 1000 ~/ 100).toString()}';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Display elapsed time
          ValueListenableBuilder<Duration>(
            valueListenable: widget.elapsedTime, 
            builder:(context, elapsedTime, child){
              return Text(
                _formatElapsedTime(elapsedTime),
                style: const TextStyle(fontSize: 40.0),
              );  
            }
          ),

          const SizedBox(height: 20.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: Provider.of<ChartsData>(context, listen: false).charts.isEmpty
                  ? null : widget.toggleStopwatch,
                child: Text(widget.stopwatchRunning.value? 'Stop Session' : 'Start Session'),
              ),
              const SizedBox(width: 10.0),
              ElevatedButton(
                onPressed: 
                  (widget.elapsedTime.value.inMilliseconds == 0)
                    ? null : widget.download,
                child: Icon(Icons.download),
              ),
              const SizedBox(width: 10.0),
              ElevatedButton(
                onPressed: (widget.elapsedTime.value.inMilliseconds == 0)
                  ? null : widget.clear,
                child: Icon(Icons.replay),
              ),
            ],
          ),
        ],
      ),
    );
  }
}