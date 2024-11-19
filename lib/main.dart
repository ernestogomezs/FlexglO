import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'screens/bluetooth_off_screen.dart';
import 'screens/scan_screen.dart';
import 'widgets/sensor_window.dart';
import 'widgets/heart_window.dart';
import 'widgets/log_stopwatch.dart';
import 'widgets/charts.dart';
import 'models/chartsdata.dart';
import 'models/nodesdata.dart';
import 'utils/snackbar.dart';

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
          create: (context) => NodesData()
        ),
        ChangeNotifierProvider(
          create: (context) => ChartsData()
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
                      muscle: 'Left Bicep Brachii', 
                      muscleSite: 0,
                      node: Provider.of<NodesData>(context, listen: false).nodes[1]
                    )
                  ),
                  Positioned(
                    left: 5, top: 30, 
                    child: SensorWindowButton(
                      muscle: 'Right Bicep Brachii',
                      muscleSite: 0,
                      node: Provider.of<NodesData>(context, listen: false).nodes[4]
                    )
                  ),
                  Positioned(
                    right: 0, top: 60, 
                    child: SensorWindowButton(
                      muscle: 'Left Tricep Brachii',
                      muscleSite: 1,
                      node: Provider.of<NodesData>(context, listen: false).nodes[1]
                    )
                  ),
                  Positioned(
                    left: 0, top: 60, 
                    child: SensorWindowButton(
                      muscle: 'Right Tricep Brachii',
                      muscleSite: 1,
                      node: Provider.of<NodesData>(context, listen: false).nodes[4]
                    )
                  ),
                  Positioned(
                    right: 60, top: 70, 
                    child: SensorWindowButton(
                      muscle: 'Left Pectoralis Major',
                      muscleSite: 0,
                      node: Provider.of<NodesData>(context, listen: false).nodes[0]
                    )
                  ),
                  Positioned(
                    left: 60, top: 70, 
                    child: SensorWindowButton(
                      muscle: 'Right Pectoralis Major',
                      muscleSite: 1,
                      node: Provider.of<NodesData>(context, listen: false).nodes[0]
                    )
                  ),
                  Positioned(
                    right: 30, bottom: 60, 
                    child: SensorWindowButton(
                      muscle: 'Left Latissimus Dorsi',
                      muscleSite: 1,
                      node: Provider.of<NodesData>(context, listen: false).nodes[2]
                    )
                  ),
                  Positioned(
                    left: 30, bottom: 60, 
                    child: SensorWindowButton(
                      muscle: 'Right Latissimus Dorsi',
                      muscleSite: 1,
                      node: Provider.of<NodesData>(context, listen: false).nodes[3]
                    )
                  ),
                  Positioned(
                    right: 40, top: 40, 
                    child: SensorWindowButton(
                      muscle: 'Left Deltoid (Shoulder)',
                      muscleSite: 0,
                      node: Provider.of<NodesData>(context, listen: false).nodes[2]
                    )
                  ),
                  Positioned(
                    left: 40, top: 40, 
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

class LogPage extends StatefulWidget{
  const LogPage({Key? key}) : super(key: key);

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final Stopwatch _stopwatch = Stopwatch();
  late ValueNotifier<Duration> _elapsedTime;
  late Timer _timer;

  @override
  initState(){
    super.initState();

    _elapsedTime.value = Duration.zero;

    // Create a timer that runs a callback every 100 milliseconds to update UI
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        // Update elapsed time only if the stopwatch is running
        if (_stopwatch.isRunning) {
          _updateElapsedTime();
        }
      });
    });
  }

  // Start/Stop button callback
  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      // Start the stopwatch and update elapsed time
      _stopwatch.start();
      _updateElapsedTime();
    } else {
      // Stop the stopwatch
      _stopwatch.stop();
    }
  }
  
  // Reset button callback
  void _resetStopwatch() {
    // Reset the stopwatch to zero and update elapsed time
    _stopwatch.reset();
    _updateElapsedTime();
  }

  // Update elapsed time and formatted time string
  void _updateElapsedTime() {
    setState(() {
      _elapsedTime.value = _stopwatch.elapsed;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Log Data'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Charts(_elapsedTime),
            const SizedBox(height: 20.0),
            LogStopwatch(_startStopwatch, _resetStopwatch, _elapsedTime),
          ],
        ),
      ),
    );
  }
}