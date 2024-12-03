import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/models/nodesdata.dart';
import '/widgets/sensor_window.dart';
import '/widgets/heart_window.dart';

class WindowMannequin extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children:<Widget>[
              SvgPicture.asset(
                'assets/images/men_vector.svg', 
              ),
              Align(
                alignment: Alignment(0.85, -0.53),
                child: SensorWindowButton(
                  muscle: 'Left Bicep Brachii', 
                  muscleSite: 0,
                  node: Provider.of<NodesData>(context, listen: false).nodes[1]
                )
              ),
              Align(
                alignment: Alignment(-0.85, -0.53),
                child: SensorWindowButton(
                  muscle: 'Right Bicep Brachii',
                  muscleSite: 0,
                  node: Provider.of<NodesData>(context, listen: false).nodes[4]
                )
              ),
              Align(
                alignment: Alignment(0.95, -0.20),
                child: SensorWindowButton(
                  muscle: 'Left Tricep Brachii',
                  muscleSite: 1,
                  node: Provider.of<NodesData>(context, listen: false).nodes[1]
                )
              ),
              Align(
                alignment: Alignment(-0.95, -0.20),
                child: SensorWindowButton(
                  muscle: 'Right Tricep Brachii',
                  muscleSite: 1,
                  node: Provider.of<NodesData>(context, listen: false).nodes[4]
                )
              ),
              Align(
                alignment: Alignment(0.45, -0.13),
                child: SensorWindowButton(
                  muscle: 'Left Pectoralis Major',
                  muscleSite: 0,
                  node: Provider.of<NodesData>(context, listen: false).nodes[0]
                )
              ),
              Align(
                alignment: Alignment(-0.45, -0.13),
                child: SensorWindowButton(
                  muscle: 'Right Pectoralis Major',
                  muscleSite: 1,
                  node: Provider.of<NodesData>(context, listen: false).nodes[0]
                )
              ),
              Align(
                alignment: Alignment(0.50, 0.35),
                child: SensorWindowButton(
                  muscle: 'Left Latissimus Dorsi',
                  muscleSite: 1,
                  node: Provider.of<NodesData>(context, listen: false).nodes[2]
                )
              ),
              Align(
                alignment: Alignment(-0.50, 0.35),
                child: SensorWindowButton(
                  muscle: 'Right Latissimus Dorsi',
                  muscleSite: 1,
                  node: Provider.of<NodesData>(context, listen: false).nodes[3]
                )
              ),
              Align(
                alignment: Alignment(0.55, -0.45),
                child: SensorWindowButton(
                  muscle: 'Left Deltoid (Shoulder)',
                  muscleSite: 0,
                  node: Provider.of<NodesData>(context, listen: false).nodes[2]
                )
              ),
              Align(
                alignment: Alignment(-0.55, -0.45),
                child: SensorWindowButton(
                  muscle: 'Right Deltoid (Shoulder)',
                  muscleSite: 0,
                  node: Provider.of<NodesData>(context, listen: false).nodes[3]
                )
              ),
              Align(
                child: HeartWindowButton(
                  Provider.of<NodesData>(context, listen: false).nodes[0]
                )
              )
            ]
          ),
        ),
      ),
    );
  }
}