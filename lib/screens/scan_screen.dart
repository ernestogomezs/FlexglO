import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/node.dart';
import '../utils/snackbar.dart';
import '../widgets/scan_result_tile.dart';
import '../widgets/node_tile.dart';
import '../utils/extra.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key, required this.nodes}) : super(key: key);

  final List<Node> nodes;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<ScanResult> _scanResults = [];
  bool _allNodesConnected = false;
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  final ValueNotifier<int> _value = ValueNotifier<int>(0);

  int amtNodes = 1;

  //Remote IDs
  final List<String> SCANFORDEVICES = [
    //"D0E9572B-E96D-AB52-92E8-3B056AD4ED67", //Ernesto's MacBook
    "BB5CD5C3-60B2-9242-E6DD-FFF87A82F877", //Debug Node 0 (Central Module)
    "1B3BA213-CCAE-5CA6-3BCD-76BD84855F9B", //Debug Node 1
    "EECB4389-2FEE-60DE-9F65-A1088A5E32AF", //Debug Node 2
  ];

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
    var newNode =  Node(result.device);
    newNode.init();
    widget.nodes[0] = newNode;
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

  // void onConnectPressed(BluetoothDevice device) {
  //   device.connectAndUpdateStream().catchError((e) {
  //     Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
  //   });
  //   MaterialPageRoute route = MaterialPageRoute(
  //       builder: (context) => DeviceScreen(device: device), settings: RouteSettings(name: '/DeviceScreen'));
  //   Navigator.of(context).push(route);
  // }

  Future onRefresh() {
    if (_isScanning == false) {
      // Get the remote Ids of the connected nodes

      // Scan the BLE devices in the netword with the allowed remote IDs, 
      // excluding the ones that are already connected
      FlutterBluePlus.startScan(
        withRemoteIds: SCANFORDEVICES, 
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
    return widget.nodes
      .map(
        (d) => NodeTile(
          node: d,
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
        floatingActionButton: buildConnectAllButton(context),
      ),
    );
  }
}