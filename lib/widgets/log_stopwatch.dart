import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/chartsdata.dart';

class LogStopwatch extends StatefulWidget{
  LogStopwatch(this.download,{Key? key}) : super(key: key);

  final VoidCallback? download;

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
            valueListenable: Provider.of<ChartsData>(context, listen: false).elapsedTime, 
            builder:(context, elapsedTime, child){
              return Text(
                _formatElapsedTime(elapsedTime),
                style: const TextStyle(fontSize: 40.0),
              );  
            }
          ),

          const SizedBox(height: 20.0),

          Consumer<ChartsData>(
            builder: (context, chartsData, child){
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: chartsData.charts.isEmpty
                      ? null : chartsData.toggleStopwatch,
                    child: Text(chartsData.stopwatchRunning.value? 'Stop Session' : 'Start Session'),
                  ),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: 
                      (chartsData.elapsedTime.value.inMilliseconds == 0)
                        ? null : widget.download,
                    child: Icon(Icons.download),
                  ),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: (chartsData.elapsedTime.value.inMilliseconds == 0)
                      ? null : () => chartsData.reset(),
                    child: Icon(Icons.replay),
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }
}