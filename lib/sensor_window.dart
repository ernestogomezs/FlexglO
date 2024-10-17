import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';

// import 'hero_dialog_route.dart';

class SensorWindowButton extends StatelessWidget{
  // const SensorWindowButton({super.key});
  final String muscle;

  SensorWindowButton(this.muscle);

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
          MaterialPageRoute(builder: (context){
              return SensorWindow();
            }
          ));
        },
        child: Hero(
          tag: muscle,
          child: Material(
            color: Colors.blueGrey,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22)
            ),
            child: const Icon(
              Icons.circle,
              size: 26,
              color: Colors.white
            ),
          )
        ),
      ),
    );




    // return Padding(
    //   padding: const EdgeInsets.all(32.0),
    //   child: GestureDetector(
    //     onTap: () {
    //       Navigator.of(context).push(HeroDialogRoute(
    //         builder: (context){
    //           return _SensorWindowPopupCard();
    //         }
    //       ));
    //     },
    //     child: Hero(
    //       tag: _heroSensorWindow,
    //       child: Material(
    //         color: Colors.blueGrey,
    //         elevation: 2,
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(22)
    //         ),
    //         child: const Icon(
    //           Icons.circle,
    //           size: 26,
    //           color: Colors.white
    //         ),
    //       )
    //     ),
    //   )
    // );
  }
}

class SensorWindow extends StatefulWidget {
  @override
  _SensorWindowState createState() => _SensorWindowState();
}

class _SensorWindowState extends State<SensorWindow> {
  List<double> traceSine = [];
  double radians = 0.0;
  Timer? _timer;

  /// method to generate a Test  Wave Pattern Sets
  /// this gives us a value between +1  & -1 for sine & cosine
  _generateTrace(Timer t) {
    // generate our  values
    var sv = sin((radians * pi));

    // Add to the growing dataset
    setState(() {
      traceSine.add(sv);
    });

    // adjust to recyle the radian value ( as 0 = 2Pi RADS)
    radians += 0.05;
    if (radians >= 2.0) {
      radians = 0.0;
    }
  }

  @override
  initState() {
    super.initState();
    // create our timer to generate test values
    _timer = Timer.periodic(Duration(milliseconds: 60), _generateTrace);
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    Oscilloscope scopeOne = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.orange,
      margin: EdgeInsets.all(20.0),
      strokeWidth: 1.0,
      backgroundColor: Colors.black,
      traceColor: Colors.green,
      yAxisMax: 1.0,
      yAxisMin: -1.0,
      dataSet: traceSine,
    );

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(flex: 1, child: scopeOne)
        ],
      ),
    );
    // return Center(
    //   child: Padding(
    //     padding: const EdgeInsets.all(32.0),
    //     child: Hero(
    //       tag:_heroSensorWindow,
    //       child: Material(
    //         color: Colors.white,
    //         elevation: 2,
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(32)
    //         ),
    //         child: SingleChildScrollView(
    //           child: Padding(
    //             padding: const EdgeInsets.all(16.0),
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               children: [
    //                 //Exit button
    //                   Hero
    //                 //Title
    //                   Text('Window')
    //                 //Oscilloscope View
    //                 //Color Change
    //               ]
    //             )
    //           )
    //         ),
    //       )
    //     )
    //   )
    // );
  }
}


