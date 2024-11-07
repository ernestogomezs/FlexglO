import 'package:flutter/material.dart';

class NodeTile extends StatefulWidget {
  NodeTile({Key? key, 
    required this.nodeId,
    required this.serviceUuidNotifier,
    required this.connectionNotifier, 
    required this.flexNotifier,
  });

  final String nodeId;
  final ValueNotifier<String> serviceUuidNotifier;
  final ValueNotifier<bool> connectionNotifier;
  final ValueNotifier<List<int>> flexNotifier;

  @override
  State<NodeTile> createState() => _NodeTileState();
}

class _NodeTileState extends State<NodeTile> {
  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Node ${widget.nodeId}",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
      ],
    );
  }

  Widget _buildConnectedStatusLight(){
    return ValueListenableBuilder<bool>(
      valueListenable: widget.connectionNotifier,
      builder: (context, isConnected, child){
        return CircleAvatar(
          backgroundColor: isConnected? Colors.green : Colors.orange,
          radius: 5,
        );
      } 
    );
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlexRow(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: ValueListenableBuilder<List<int>>(
              valueListenable: widget.flexNotifier,
              builder: (context, flexBytes, child){
                return Text(
                    flexBytes.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.black),
                  );
              },
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.connectionNotifier,
      builder: (context, isConnected, child){
        return ExpansionTile(
          collapsedBackgroundColor: Colors.grey,
          backgroundColor: Colors.grey,
          title: _buildTitle(context),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildConnectedStatusLight(),
            ]
          ),
          children: <Widget>[
            ValueListenableBuilder<String>(
              valueListenable: widget.serviceUuidNotifier,
              builder: (context, service_uuid, child) {
                return isConnected ?
                  _buildAdvRow(context,
                    "Device's Remote UUID",
                    service_uuid.toUpperCase()
                  ) : Container();
              }
            ),  
            Builder(
              builder: (context) {
                return isConnected ?
                  _buildFlexRow(context,
                    "Flex Values"
                  ) : Container();
              }
            ) 
          ] 
        );
      }
    );
  }
}