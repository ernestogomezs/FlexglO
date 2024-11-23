import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/models/nodesdata.dart';
import '/widgets/sensor_window.dart';
import '/widgets/heart_window.dart';

class WindowMannequin extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children:<Widget>[
          SvgPicture.asset(
            'assets/images/men_vector.svg', 
          ),
          Positioned(
            right: 5, top: 60, 
            child: SensorWindowButton(
              muscle: 'Left Bicep Brachii', 
              muscleSite: 0,
              node: Provider.of<NodesData>(context, listen: false).nodes[1]
            )
          ),
          Positioned(
            left: 5, top: 60, 
            child: SensorWindowButton(
              muscle: 'Right Bicep Brachii',
              muscleSite: 0,
              node: Provider.of<NodesData>(context, listen: false).nodes[4]
            )
          ),
          Positioned(
            right: 0, top: 100, 
            child: SensorWindowButton(
              muscle: 'Left Tricep Brachii',
              muscleSite: 1,
              node: Provider.of<NodesData>(context, listen: false).nodes[1]
            )
          ),
          Positioned(
            left: 0, top: 100, 
            child: SensorWindowButton(
              muscle: 'Right Tricep Brachii',
              muscleSite: 1,
              node: Provider.of<NodesData>(context, listen: false).nodes[4]
            )
          ),
          Positioned(
            right: 60, top: 110, 
            child: SensorWindowButton(
              muscle: 'Left Pectoralis Major',
              muscleSite: 0,
              node: Provider.of<NodesData>(context, listen: false).nodes[0]
            )
          ),
          Positioned(
            left: 60, top: 110, 
            child: SensorWindowButton(
              muscle: 'Right Pectoralis Major',
              muscleSite: 1,
              node: Provider.of<NodesData>(context, listen: false).nodes[0]
            )
          ),
          Positioned(
            right: 60, bottom: 70, 
            child: SensorWindowButton(
              muscle: 'Left Latissimus Dorsi',
              muscleSite: 1,
              node: Provider.of<NodesData>(context, listen: false).nodes[2]
            )
          ),
          Positioned(
            left: 60, bottom: 70, 
            child: SensorWindowButton(
              muscle: 'Right Latissimus Dorsi',
              muscleSite: 1,
              node: Provider.of<NodesData>(context, listen: false).nodes[3]
            )
          ),
          Positioned(
            right: 50, top: 70, 
            child: SensorWindowButton(
              muscle: 'Left Deltoid (Shoulder)',
              muscleSite: 0,
              node: Provider.of<NodesData>(context, listen: false).nodes[2]
            )
          ),
          Positioned(
            left: 50, top: 70, 
            child: SensorWindowButton(
              muscle: 'Right Deltoid (Shoulder)',
              muscleSite: 0,
              node: Provider.of<NodesData>(context, listen: false).nodes[3]
            )
          ),
          Positioned(
            child: HeartWindowButton(
              Provider.of<NodesData>(context, listen: false).nodes[0]
            )
          )
        ]
      ),
    );
  }
}