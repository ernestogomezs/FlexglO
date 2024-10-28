import 'dart:async';


import '../utils/node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class NodeTile extends StatefulWidget {
  NodeTile({Key? key, required this.node});

  final Node node;

  @override
  State<NodeTile> createState() => _NodeTileState();
}

class _NodeTileState extends State<NodeTile> {
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;

  @override
  void initState() {
    super.initState();
    _connectionStateSubscription = widget.node.device.connectionState.listen((state) async {
      _connectionState = state;
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]';
  }

  String getNiceManufacturerData(List<List<int>> data) {
    return data.map((val) => getNiceHexArray(val)).join(', ').toUpperCase();
  }

  String getNiceServiceData(Map<Guid, List<int>> data) {
    return data.entries.map((v) => '${v.key}: ${getNiceHexArray(v.value)}').join(', ').toUpperCase();
  }

  String getNiceServiceUuids(List<Guid> serviceUuids) {
    return serviceUuids.join(', ').toUpperCase();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Node ${widget.node.id.toString()}",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
      ],
    );
  }

  Widget _buildConnectedStatusLight(){
    return CircleAvatar(
      backgroundColor: isConnected? Colors.green : Colors.orange,
      radius: 5,
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

  Widget _buildListenableRow(BuildContext context, String title) {
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
              valueListenable: widget.node.valuebytesL,
              builder: (BuildContext context, List<int> value, Widget? child){
                return Text(
                  value.toString(),
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
  //   var adv = widget.result.advertisementData;
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
      // leading: Text(widget.result.rssi.toString()),
      // trailing: _buildConnectButton(context),
      children: <Widget>[
        _buildAdvRow(context,
          "Device's Remote UUID", widget.node.device.remoteId.str,
        ),
        if(isConnected) _buildAdvRow(context,
          "Service UUID", widget.node.service.serviceUuid.toString().toUpperCase(), 
        ),
        if(isConnected) _buildListenableRow(context,
          "Characteristic Value"
        ),
        // for(BluetoothService service in widget.result.device.servicesList){
        //   for (BluetoothCharacteristic characteristic in service.characteristics){
        //     _buildAdvRow(
        //       context, "Data from Service" + service. , "TOBEHERE"
        //       // String.fromCharCodes(widget.value)
        //     )
        //   }
        // }
        // if (adv.advName.isNotEmpty) _buildAdvRow(context, 'Name', adv.advName),
        // if (adv.txPowerLevel != null) _buildAdvRow(context, 'Tx Power Level', '${adv.txPowerLevel}'),
        // if ((adv.appearance ?? 0) > 0) _buildAdvRow(context, 'Appearance', '0x${adv.appearance!.toRadixString(16)}'),
        // if (adv.msd.isNotEmpty) _buildAdvRow(context, 'Manufacturer Data', getNiceManufacturerData(adv.msd)),
        // if (adv.serviceUuids.isNotEmpty) _buildAdvRow(context, 'Service UUIDs', getNiceServiceUuids(adv.serviceUuids)),
        // if (adv.serviceData.isNotEmpty) _buildAdvRow(context, 'Service Data', getNiceServiceData(adv.serviceData)),
      ],
    );
  }
}

