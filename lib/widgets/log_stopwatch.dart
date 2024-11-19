import 'dart:async';

import 'package:flutter/material.dart';

class LogStopwatch extends StatefulWidget{
  LogStopwatch(this.startStopwatch, 
               this.resetStopwatch,
               this.elapsedTimeListener,
               {Key? key}) : super(key: key);

  final VoidCallback? startStopwatch;
  final VoidCallback? resetStopwatch;
  final ValueNotifier<Duration> elapsedTimeListener;

  @override
  State<LogStopwatch> createState() => _LogStopwatchState();
}

class _LogStopwatchState extends State<LogStopwatch>{
  final Stopwatch _stopwatch = Stopwatch();
  late Timer timer;

  // Format a Duration into a string (MM:SS.SS)
  String _formatElapsedTime(Duration time) {
    return '${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(time.inMilliseconds % 1000 ~/ 100).toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Display elapsed time
          ValueListenableBuilder<Duration>(
            valueListenable: widget.elapsedTimeListener, 
            builder:(context, elapsedTime, child){
              return Text(
                _formatElapsedTime(elapsedTime),
                style: const TextStyle(fontSize: 40.0),
              );  
            }
          ),
          const SizedBox(height: 20.0),
          // Start/Stop and Reset buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: widget.resetStopwatch,
                child: const Text('Reset'),
              ),
              const SizedBox(width: 20.0),
              ElevatedButton(
                onPressed: widget.startStopwatch,
                child: Text(_stopwatch.isRunning ? 'Stop Session' : 'Start Session'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}