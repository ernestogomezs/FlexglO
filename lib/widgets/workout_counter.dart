import 'package:flexglow_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/workout.dart';

class WorkoutCounterWidget extends StatefulWidget {
  WorkoutCounterWidget(this.direction, {Key? key}) : super(key : key);

  final Axis direction;

  @override
  State<WorkoutCounterWidget> createState() => WorkoutCounterWidgetState();
}

class WorkoutCounterWidgetState extends State<WorkoutCounterWidget> {
  @override
  Widget build(BuildContext context) {
    WorkoutCounter workoutCounter = Provider.of<Workout>(context, listen:false).workoutCounter;
    int exerciseIndex = 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        direction: Axis.vertical,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: Colors.black,
                width: 2
              )
            ),
            child: SizedBox(
              child: ToggleLayoutWidget(
                  direction: widget.direction,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ...workoutCounter.counter.map((exercise){
                      return buildExerciseCounter(exercise, exerciseIndex++);
                    }).toList(),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () => workoutCounter.reset(),
                          child: Icon(Icons.refresh),
                        ),
                      ),
                    )
                  ] 
                ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExerciseCounter(ValueNotifier<int> count, int index){
    return Expanded(
      flex: 1,
      child: Center(
        child: FittedBox(
          child: Column(
              children: [
                ValueListenableBuilder(
                  valueListenable: count, 
                  builder: (context, value, child){
                    return Text(
                      "$value",
                      style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0)
                    );
                  }
                ),
                Text(
                  Exercises.values[index].toString(),
                  style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0),
                ),
              ]
          ),
        ),
      ),
    );
  }
}

class ToggleLayoutWidget extends StatelessWidget {
  final Axis direction;
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ToggleLayoutWidget({
    Key? key,
    required this.direction,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.horizontal) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    } else {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }
  }
}

