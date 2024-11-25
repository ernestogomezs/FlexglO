import 'package:flexglow_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/workout.dart';

class WorkoutTable extends StatelessWidget {
  Widget buildArrayWidget(List<List<int>> array, Color color, Axis direction, {bool isRepTable = false}) {
    int index = 0;
    if(array.isEmpty){
      return Text("No recorded reps", style: TextStyle(fontWeight: FontWeight.bold),);
    }
    else{
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...array.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              ...row.map((item) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: (direction == Axis.vertical)? 4.0 : 0,
                  vertical: (direction == Axis.vertical)? 0 : 4
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 5.0
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SizedBox(
                  width: 10,
                  child: Center(
                    child: Text(
                      item.toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            }).toList(),
            ]
          );
        }).toList()
        ]
      );
    }
  }

  Widget buildRowWidget(List<int> row){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: row.map((item) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            item.toString(),
            style: TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget buildColumnWidget(List<Pair> column){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: column.map((item) {
        return Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(item.muscleGroup.toString()),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                item.sum.toString(),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: <Widget>[
            Text(
              "Last Recorded \nMuscle Activation", 
              softWrap: true,
              textAlign: TextAlign.center,
            ), 
            ValueListenableBuilder(
              valueListenable: Provider.of<Workout>(context, listen: false).functors, 
              builder: (context, muscleRow, child){
                var row = muscleRow.map((val) => val.value).toList();
                return buildRowWidget(row);
              }
            ),
            Text("Rep Table"), 
            ValueListenableBuilder(
              valueListenable: Provider.of<Workout>(context, listen: false).table, 
              builder: (context, table, child){
                return buildArrayWidget(table, Colors.blue, Axis.vertical);
              }
            ),
          ]
        ),
        Column(
          children: [
            Text("Last Recorded Rep"), 
            Builder(
              builder: (context){
                List<Widget> list = [];
                for(int i = 0; i < MUSCLECOUNT; ++i){
                  list.add(SizedBox(
                    width: 30,
                    child: Text(
                      MuscleGroups.values[i].toString()[0],
                      textAlign: TextAlign.center,
                    ),
                  ));
                }
                return Row(
                  children: list,
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: Provider.of<Workout>(context, listen: false).lastRep, 
              builder: (context, table, child){
                return buildArrayWidget(table, Colors.green, Axis.vertical);
              }
            ),

            SizedBox(height: 100),

            Text("Muscle Rankings"), 
            ValueListenableBuilder(
              valueListenable: Provider.of<Workout>(context, listen: false).rankings, 
              builder: (context, table, child){
                return buildColumnWidget(table);
              }
            ),
          ]
        )
      ],
    );
  }
}

