import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/models/nodesdata.dart';

import '/utils/constants.dart';

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
                'assets/images/men_vector2.svg', 
              ),
              // Builder(
              //   builder: (context){
              //     List<Widget> list = [];
              //     for(int i = 0; i < MUSCLECOUNT; i++){
              //       list += Align(
              //         alignment: BUTTON_ALIGNMENTS[i],
              //         child: SensorWindowButton(
              //           muscle: MUSCLESITES[i], 
              //           muscleSite: muscleSite, 
              //           node: node
              //         )
              //       )
              //     }
              //     return list;
              //   },
              // ),
              Align(
                alignment: Alignment(0.75, -0.45),
                child: SensorWindowButton(
                  muscle: MUSCLESITES[0], 
                  muscleSite: 0,
                  node: Provider.of<NodesData>(context, listen: false).nodes[1]
                )
              ),
              Align(
                alignment: Alignment(-0.75, -0.45),
                child: SensorWindowButton(
                  muscle: MUSCLESITES[1],
                  muscleSite: 1,
                  node: Provider.of<NodesData>(context, listen: false).nodes[4]
                )
              ),
              Align(
                alignment: Alignment(0.85, -0.10),
                child: SensorWindowButton(
                  muscle: MUSCLESITES[2],
                  muscleSite: 1,
                  node: Provider.of<NodesData>(context, listen: false).nodes[1]
                )
              ),
              Align(
                alignment: Alignment(-0.85, -0.10),
                child: SensorWindowButton(
                  muscle: MUSCLESITES[3],
                  muscleSite: 0,
                  node: Provider.of<NodesData>(context, listen: false).nodes[4]
                )
              ),
              Align(
                alignment: Alignment(0.35, -0.13),
                child: SensorWindowButton(
                  muscle: MUSCLESITES[4],
                  muscleSite: 1,
                  node: Provider.of<NodesData>(context, listen: false).nodes[0]
                )
              ),
              Align(
                alignment: Alignment(-0.35, -0.13),
                child: SensorWindowButton(
                  muscle: MUSCLESITES[5],
                  muscleSite: 0,
                  node: Provider.of<NodesData>(context, listen: false).nodes[0]
                )
              ),
              Align(
                alignment: Alignment(0.40, 0.35),
                child: SensorWindowButton(
                  muscle: MUSCLESITES[6],
                  muscleSite: 1,
                  node: Provider.of<NodesData>(context, listen: false).nodes[2]
                )
              ),
              Align(
                alignment: Alignment(-0.40, 0.35),
                child: SensorWindowButton(
                  muscle: MUSCLESITES[7],
                  muscleSite: 0,
                  node: Provider.of<NodesData>(context, listen: false).nodes[3]
                )
              ),
              Align(
                alignment: Alignment(0.5, -0.4),
                child: SensorWindowButton(
                  muscle: MUSCLESITES[8],
                  muscleSite: 0,
                  node: Provider.of<NodesData>(context, listen: false).nodes[2]
                )
              ),
              Align(
                alignment: Alignment(-0.5, -0.4),
                child: SensorWindowButton(
                  muscle: MUSCLESITES[9],
                  muscleSite: 1,
                  node: Provider.of<NodesData>(context, listen: false).nodes[3]
                )
              ),
              Align(
                child: HeartWindowButton(
                  node: Provider.of<NodesData>(context, listen: false).nodes[0]
                )
              )
            ]
          ),
        ),
      ),
    );
  }
}