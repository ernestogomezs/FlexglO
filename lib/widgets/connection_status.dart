import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/nodesdata.dart';
import '/utils/node.dart';

class ConnectionConsole extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: Provider.of<NodesData>(context, listen:false).nodes
            .map(
            (n) => ConnectionStatus(
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

class ConnectionStatus extends StatefulWidget {
  ConnectionStatus(this.node, {Key? key}) : super(key: key);

  final Node node;

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {

// THESE TWO METHODS ARE COPIES FROM node_tile.dart, WOULD BE NICE TO 
// REFACTOR CODE AND MAKE A PARENT CLASS TO MODIFY BOTH IN ONE RUN.
  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Node ${widget.node.id}",
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
  Widget _buildConnectedStatusLight(){
    return ValueListenableBuilder<bool>(
      valueListenable: widget.node.connectionStateNotifier,
      builder: (context, isConnected, child){
        return CircleAvatar(
          backgroundColor: isConnected? Colors.green : Colors.orange,
          radius: 5,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black
          ),
          borderRadius: BorderRadius.circular(4)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTitle(context),
            _buildConnectedStatusLight()
          ]
        ),
      ),
    );
  }
}