import 'package:flutter/material.dart';

class WorkoutCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: Provider.of<NodesData>(context, listen:false).nodes
            .map(
            (n) => (
              n,
            )
          ).toList()
        ),
        Text(
          "Connection Status",
          style: TextStyle(
            //fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 18
          )
        ), 
      ]
    );
  }
}