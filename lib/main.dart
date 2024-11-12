import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'screens/bluetooth_off_screen.dart';
import 'screens/scan_screen.dart';
import '../widgets/sensor_window.dart';
import '../utils/node.dart';
import '../utils/snackbar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'FlexGlow App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<Node> nodes = [Node.def(0), Node.def(1), Node.def(2), Node.def(3), Node.def(4)];
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> adapterStateStateSubscription;

  void initState(){
    adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      print(state.toString());
      adapterState = state;
      notifyListeners();
    });
  }

  @override
  void dispose(){
    adapterStateStateSubscription.cancel();
    super.dispose();
  }

  void replaceNode(index, newNode){
    nodes[index] = newNode;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    appState.initState();
    Widget page;
    switch (selectedIndex){ 
      case 0:
        page = NodesPage();
      case 1:
        page = BluetoothPage();
      case 2:
        page = LogPage();
      case 3:
        page = Placeholder();
      case 4:
        page = Placeholder();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bluetooth),
                      label: Text('Bluetooth'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.assessment),
                      label: Text('Assessment'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.fitness_center),
                      label: Text('Fitness Center'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    )
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState((){
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class NodesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyA,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Central - Examine Nodes'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: AlignmentDirectional.center,
                children:<Widget>[
                  SvgPicture.asset(
                    'assets/images/men_vector.svg', 
                    width: 250,
                    height: 250
                  ),
                  // **Number explanations:**
                  // Center node is node 0
                  // Muscle sites are numbered up to down, left to right
                  // Other nodes are 1-4, left to right
                  // example: left arm node is node 1, right arm is node 4
                  //
                  // Muscle sites are numbered up to down and left to right 
                  // on the guy flexing, heart is the only muscle site with #2
                  // example: bicep is muscle 0, tricep is muscle 1
                  Positioned(
                    right: 5, top: 30, 
                    child: SensorWindowButton(
                      muscle: 'Left Bicep', 
                      muscleSite: 0,
                      nodeID: '1',
                      flexNotifier: appState.nodes[1].m0Notifier,
                      connectionStateNotifier: appState.nodes[1].connectionStateNotifier,
                      writeColorChange : appState.nodes[1].writeGloColor
                    )
                  ),
                  Positioned(
                    left: 5, top: 30, 
                    child: SensorWindowButton(
                      muscle: 'Right Bicep',
                      muscleSite: 0,
                      nodeID: '4',
                      flexNotifier: appState.nodes[4].m0Notifier,
                      connectionStateNotifier: appState.nodes[4].connectionStateNotifier,
                      writeColorChange: appState.nodes[4].writeGloColor
                    )
                  ),
                  Positioned(
                    right: 0, top: 60, 
                    child: SensorWindowButton(
                      muscle: 'Left Tricep',
                      nodeID: '1',
                      muscleSite: 1,
                      flexNotifier: appState.nodes[1].m1Notifier,
                      connectionStateNotifier: appState.nodes[4].connectionStateNotifier,
                      writeColorChange: appState.nodes[1].writeGloColor
                    )
                  ),
                  Positioned(
                    left: 0, top: 60, 
                    child: SensorWindowButton(
                      muscle: 'Right Tricep',
                      nodeID: '4',
                      muscleSite: 1,
                      flexNotifier: appState.nodes[4].m1Notifier,
                      connectionStateNotifier: appState.nodes[4].connectionStateNotifier,
                      writeColorChange: appState.nodes[4].writeGloColor
                    )
                  ),
                  Positioned(
                    right: 60, top: 70, 
                    child: SensorWindowButton(
                      muscle: 'Left Pectoral',
                      nodeID: '0',
                      muscleSite: 0,
                      flexNotifier: appState.nodes[0].m0Notifier,
                      connectionStateNotifier: appState.nodes[0].connectionStateNotifier,
                      writeColorChange: appState.nodes[0].writeGloColor
                    )
                  ),
                  Positioned(
                    left: 60, top: 70, 
                    child: SensorWindowButton(
                      muscle: 'Right Pectoral',
                      nodeID: '0',
                      muscleSite: 1,
                      flexNotifier: appState.nodes[0].m1Notifier,
                      connectionStateNotifier: appState.nodes[0].connectionStateNotifier,
                      writeColorChange: appState.nodes[0].writeGloColor
                    )
                  ),
                  Positioned(
                    right: 30, bottom: 60, 
                    child: SensorWindowButton(
                      muscle: 'Left Deltoid',
                      nodeID: '2',
                      muscleSite: 1,
                      flexNotifier: appState.nodes[2].m1Notifier,
                      connectionStateNotifier: appState.nodes[2].connectionStateNotifier,
                      writeColorChange: appState.nodes[2].writeGloColor
                    )
                  ),
                  Positioned(
                    left: 30, bottom: 60, 
                    child: SensorWindowButton(
                      muscle: 'Right Deltoid',
                      nodeID: '3',
                      muscleSite: 1,
                      flexNotifier: appState.nodes[3].m1Notifier,
                      connectionStateNotifier: appState.nodes[3].connectionStateNotifier,
                      writeColorChange: appState.nodes[3].writeGloColor
                    )
                  ),
                  Positioned(
                    right: 40, top: 40, 
                    child: SensorWindowButton(
                      muscle: 'Left Shoulder',
                      nodeID: '2',
                      muscleSite: 0,
                      flexNotifier: appState.nodes[2].m0Notifier,
                      connectionStateNotifier: appState.nodes[2].connectionStateNotifier,
                      writeColorChange: appState.nodes[2].writeGloColor
                    )
                  ),
                  Positioned(
                    left: 40, top: 40, 
                    child: SensorWindowButton(
                      muscle: 'Right Shoulder',
                      nodeID: '3',
                      muscleSite: 0,
                      flexNotifier: appState.nodes[3].m0Notifier,
                      connectionStateNotifier: appState.nodes[3].connectionStateNotifier,
                      writeColorChange: appState.nodes[3].writeGloColor
                    )
                  ),
                  Positioned(
                    child: SensorWindowButton(
                      muscle: 'Heart',
                      nodeID: '0',
                      muscleSite: 2,
                      flexNotifier: appState.nodes[0].bpmNotifier,
                      connectionStateNotifier: appState.nodes[0].connectionStateNotifier,
                      writeColorChange: appState.nodes[0].writeGloColor
                    )
                  )
                ]
              ),
            ]
          )
        ),
      )
    );
  }
}

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyAppState>(
      builder: (context, appState, child)=> Scaffold( 
          body: (appState.adapterState == BluetoothAdapterState.on)? 
            ScanScreen()
            : BluetoothOffScreen(adapterState: appState.adapterState),
      )
    );
  }
}

class LogPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();
    return Center();
  }

}