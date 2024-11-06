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
  List<Node> nodes = [Node.def(0)];
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
                  Positioned(
                    left: 5, top: 30, child: SensorWindowButton('Left Bicep')
                  ),
                  Positioned(
                    right: 5, top: 30, child: SensorWindowButton('Right Bicep')
                  ),
                  Positioned(
                    left: 0, top: 60, child: SensorWindowButton('Left Tricep')
                  ),
                  Positioned(
                    right: 0, top: 60, child: SensorWindowButton('Right Tricep')
                  ),
                  Positioned(
                    left: 60, top: 70, child: SensorWindowButton('Left Pectoral')
                  ),
                  Positioned(
                    right: 60, top: 70, child: SensorWindowButton('Right Pectoral')
                  ),
                  Positioned(
                    left: 30, bottom: 60, child: SensorWindowButton('Left Deltoid')
                  ),
                  Positioned(
                    right: 30, bottom: 60, child: SensorWindowButton('Right Deltoid')
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