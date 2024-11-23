import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../utils/node.dart';
import '../utils/snackbar.dart';
import '../utils/extra.dart';
import '../widgets/scan_result_tile.dart';
import '../widgets/node_tile.dart';
import '../models/nodesdata.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<ScanResult> _scanResults = [];
  bool _allNodesConnected = false;
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  int amtNodes = 1;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;

      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  onConnect(ScanResult result) async{
    try {
      await result.device.connectAndUpdateStream();
      Snackbar.show(ABC.c, "Connect: Success", success: true);
    } catch (e) {
      if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
      }
    }
    
    if(mounted){
      var newNode =  Node(result.device);
      newNode.init();
      Provider.of<NodesData>(context, listen: false).replaceNode(newNode.id, newNode);
      setState(() {});
    }
  }

  void onDisconnect(Node d) async{
    try {
      await d.device.disconnect();
      Snackbar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e) {
      if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        Snackbar.show(ABC.c, prettyException("Disconnect Error:", e), success: false);
      }
    }

    if(mounted){
      Provider.of<NodesData>(context, listen: false).replaceNode(d.id, Node.def(d.id));
      setState(() {});
    }
  }

  void onConnectAll() async{
    //ONLY ALLOW USER TO CONNECT IF ALL 5 NODES ARE FOUND IN result
    for (ScanResult result in _scanResults){ 
      await onConnect(result);
      var newNode =  Node(result.device);
      newNode.init();
    }
    _allNodesConnected = true;
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(
        withKeywords: ["Node"], 
        timeout: const Duration(seconds: 15)
      );
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(Duration(milliseconds: 500));
  }

  Widget buildConnectAllButton(BuildContext context){
    return Builder(
      builder: (context){
        if(_scanResults.length < amtNodes){
          return FloatingActionButton.extended(
            onPressed: () => {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Missing Nodes'),
                  content: const Text('Make sure all nodes are powered on and in range'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => {
                        onRefresh(),
                        Navigator.pop(context, 'OK')
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            },
            label: const Text("FIND DEVICES"),
            backgroundColor: Colors.grey, 
            foregroundColor: Colors.black,
          );
        }
        else{
          return FloatingActionButton.extended(
            onPressed: () => onConnectAll(),
            label: const Text("CONNECT ALL"),
            backgroundColor: Colors.blue, 
            foregroundColor: Colors.white,
          );
        }
      }
    );
  }

  List<Widget> _buildNodeTiles(BuildContext context) {
    return Provider.of<NodesData>(context, listen: false).nodes
      .map(
        (d) => NodeTile(
          nodeId: "${d.id}",
          serviceUuidNotifier: d.serviceUuidNotifier,
          connectionNotifier: d.connectionStateNotifier,
          flexNotifier: d.flexBytesNotifier,
          onTap: () => onDisconnect(d)
        ),
      )
    .toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
      .map(
        (r) => ScanResultTile(
          result: r,
          onTap: () => onConnect(r),
        ),
      )
      .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find Devices'),
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              Center(
                child: Text(
                "Scroll down to refresh",
                style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.grey),
              )),
              ..._buildNodeTiles(context),
              ..._buildScanResultTiles(context)
            ],
          ),
        ),
        //floatingActionButton: buildConnectAllButton(context),
      ),
    );
  }
}