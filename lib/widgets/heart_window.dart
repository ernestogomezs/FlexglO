import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;

import '../utils/node.dart';

class HeartWindowButton extends StatelessWidget{
  HeartWindowButton(this.node, {Key? key}): super (key: key);

  final Node node;

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GestureDetector(
        onTap: () {
          if(!node.connectionStateNotifier.value){
            showDialog(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Text('Node ${node.id} for heart rate data is not connected'),
                  content: Text('Make sure node ${node.id} is connected in the Bluetooth menu'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => {
                        Navigator.pop(context, 'OK')
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              }
            );
          }
          else{
            Navigator.push(context, MaterialPageRoute(
              builder: (context){
                return HeartWindow(node);
              }
            ));
          }
        },
        child: Hero(
          tag: 'Heart',
          child: Material(
            color: Colors.blueGrey,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
            ),
            child: const Icon(
              Icons.monitor_heart,
              size: 26,
              color: Colors.white //Change to listener builder with glo bytes corresponding to muscleSite 
            ),
          )
        ),
      ),
    );
  }
}

class HeartWindow extends StatefulWidget {
  HeartWindow(this.node);

  final Node node;

  @override
  State<HeartWindow> createState() => _HeartWindowState();
}

class _HeartWindowState extends State<HeartWindow> {
  List<int> trace = [];
  double radians = 0.0;
  Timer? _timer;
  Color currentColor = Color.fromRGBO(0, 0xFF, 0, 1.0);

  _beatHeart(Timer t) {
    // Animate heart to beat
  }

  @override
  initState() {
    super.initState();
    int BPMValue = widget.node.bpmNotifier.value;
    _timer = Timer.periodic(Duration(milliseconds: BPMValue), _beatHeart);
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
      yAxisColor: Colors.grey,
      margin: EdgeInsets.all(20.0),
      strokeWidth: 3.0,
      backgroundColor: Colors.white,
      traceColor: currentColor,
      yAxisMax: 2050,
      yAxisMin: 0,
      dataSet: trace,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Heart Rate"),
        backgroundColor: Colors.white
      ),
      body: Hero(
        tag: 'heart',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              // Beating heart 
              HeartAnimation(widget.node.bpmNotifier),
              ValueListenableBuilder(
                valueListenable: widget.node.bpmNotifier,
                builder:(context, bpmValue, child){
                  return Container(
                    padding: EdgeInsets.all(40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      textDirection: TextDirection.ltr,
                      children:[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Beats per minute: ",
                            style: Theme.of(context).textTheme.bodyLarge
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "$bpmValue",
                            style: Theme.of(context).textTheme.bodyLarge
                          ),
                        ),
                      ]
                    ),
                  );
                }
              )
            ]
          ),
        )
      ),
    );
  }
}

class HeartAnimation extends StatefulWidget{
  HeartAnimation(this.bpmNotifier, {Key? key}) : super(key: key);

  final ValueNotifier<int> bpmNotifier;

  @override
  HeartAnimationState createState() => HeartAnimationState();
}

class HeartAnimationState extends State<HeartAnimation> with TickerProviderStateMixin {
  late AnimationController motionController;
  late Animation motionAnimation;
  double size = 20;

  @override
  void initState() {
    super.initState();

    motionController = AnimationController(
      duration: Duration(milliseconds: (1000*(widget.bpmNotifier.value/60)).toInt()),
      vsync: this,
      lowerBound: 0.5,
    );

    motionAnimation = CurvedAnimation(
      parent: motionController,
      curve: Curves.ease,
    );

    motionController.forward();
    motionController.addStatusListener((status) {
      setState(() {
        if (status == AnimationStatus.completed) {
          motionController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          motionController.forward();
        }
      });
    });

    motionController.addListener(() {
      setState(() {
        size = motionController.value * 250;
      });
    });

    widget.bpmNotifier.addListener((){
      motionController.duration = Duration(milliseconds: (1000*(widget.bpmNotifier.value/60)).toInt());
    });
    // motionController.repeat();
  }

  @override
  void dispose() {
    motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: Icon(
        CupertinoIcons.heart_fill,
        color: Colors.red,
        size: size
      ),
    );
  }

}