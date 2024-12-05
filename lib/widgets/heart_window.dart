import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;

import '/utils/node.dart';
import '/utils/constants.dart';

class HeartWindowButton extends StatefulWidget{
  HeartWindowButton({required this.node, Key? key})
    : super(key: key,);
        
  final String _muscle =  "heart";
  final int _muscleSite = 0;
  final Node node;

  @override
  State<HeartWindowButton> createState() => _HeartWindowButtonState();
}

class _HeartWindowButtonState extends State<HeartWindowButton> {
  late Color muscleColor = widget.node.gloFromMuscle(widget._muscleSite);
  late ValueNotifier<double> _heartValue = ValueNotifier<double>(0);
  late Timer _timer;
  
  @override
  void initState() {
    widget.node.connectionStateNotifier.addListener((){
      if(widget.node.isConnected){
        muscleColor = widget.node.gloFromMuscle(widget._muscleSite);
      }
      else{
        muscleColor = Colors.black;
      }
      if(mounted){
        setState((){});
      }
    });

    widget.node.gloBytesNotifier.addListener((){
      muscleColor = widget.node.gloFromMuscle(widget._muscleSite);
      if(mounted){
        setState((){});
      }
    });
    int t = widget.node.bpmNotifier.value == 0? 0 : (BPM_TO_T_CONV/widget.node.bpmNotifier.value).toInt();
    _timer = Timer.periodic(Duration(milliseconds: t), (Timer timer) {
      //print(t);
      setState(() {
        _heartValue.value = (_heartValue.value == 0.2)? 1 : 0.2;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 400),
        closedBuilder: (context, openContainer){
          return GestureDetector(
            onTap: () {
              if(!widget.node.connectionStateNotifier.value){
                showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text('Node ${widget.node.id} for ${widget._muscle} is not connected'),
                      content: Text('Make sure node ${widget.node.id} is connected in the Bluetooth menu'),
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
                openContainer();
              }
            },
            child: Material(
              color: Colors.white,
              elevation: 2,
              child: ValueListenableBuilder(
                valueListenable: _heartValue,
                builder: (context, value, child) {
                  return Icon(
                    Icons.monitor_heart,
                    size: 26,
                    color: (widget.node.connectionStateNotifier.value)?
                      Color.fromRGBO(0xff, 0, 0, value) :
                      Colors.black
                  );
                }
              )
            )
          );
        },
        openBuilder: (context, closeContainer){
          return HeartWindow(widget.node);
        }
      )
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
    int t = widget.node.bpmNotifier.value == 0? 0 : (BPM_TO_T_CONV/widget.node.bpmNotifier.value).toInt();
    _timer = Timer.periodic(Duration(milliseconds: t), _beatHeart);
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
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
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        textDirection: TextDirection.ltr,
                        children:[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Beats per minute: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              )
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "$bpmValue",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              )
                            ),
                          ),
                        ]
                      ),
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

    int t = widget.bpmNotifier.value == 0? 0 : (BPM_TO_T_CONV/widget.bpmNotifier.value).toInt();
    motionController = AnimationController(
      
      duration: Duration(milliseconds: t),
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
      int t = widget.bpmNotifier.value == 0? 0 : (BPM_TO_T_CONV/widget.bpmNotifier.value).toInt();
      motionController.duration = Duration(milliseconds: t);
    });
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