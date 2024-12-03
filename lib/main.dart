import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'models/chartsdata.dart';
import 'models/nodesdata.dart';
import 'models/workout.dart';

import 'utils/snackbar.dart';

import 'screens/bluetooth_off_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/log_page_screen.dart';

import 'widgets/window_mannequin.dart';
import 'widgets/connection_status.dart';
import 'widgets/workout_table.dart';
import 'widgets/workout_counter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NodesData(context)
        ),
        ChangeNotifierProvider(
          create: (context) => ChartsData(context)
        ),
        ChangeNotifierProvider(
          create: (context) => Workout(context)
        ),
        ChangeNotifierProvider(
          create: (context) => MyAppState()
        ),
      ],
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
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> adapterStateStateSubscription;

  void initState(){
    adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      //print(state.toString());
      adapterState = state;
      notifyListeners();
    });
  }

  @override
  void dispose(){
    adapterStateStateSubscription.cancel();
    super.dispose();
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
        page = WorkoutPage();
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
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyA,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Central - Examine Nodes'),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ConnectionConsole(),
              WindowMannequin(),
              WorkoutCounterWidget(Axis.horizontal),
              const SizedBox(height: 60),
            ]
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
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Log Data'),
        ),
        body: LogPageScreen()
      ),
    );
  }
}

class WorkoutPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout Data'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:<Widget>[
            Expanded(child: WorkoutTable()),
            const SizedBox(height: 20.0),
            WorkoutCounterWidget(Axis.horizontal),
            const SizedBox(height: 60),
          ]
        ),
      ),
    );
  }
}