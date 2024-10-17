//import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:oscilloscope/oscilloscope.dart';

import 'sensor_window.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
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
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
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
    Widget page;
    switch (selectedIndex){ 
      case 0:
        page = GeneratorPage();
      case 1:
        page = Placeholder();
      case 2:
        page = FavoritesPage();
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


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    //var pair = appState.current;

    // IconData icon;
    // if (appState.favorites.contains(pair)) {
    //   icon = Icons.favorite;
    // } else {
    //   icon = Icons.favorite_border;
    // }

    return Center(
      // child: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
        child:Stack(
          alignment: AlignmentDirectional.center,
          children:<Widget>[
            SvgPicture.asset(
                  'assets/images/men_vector.svg', 
                  width: 250,
                  height: 250
            ),
            Positioned(
              left: 5,
              top: 30,
              child: SensorWindowButton('leftBicep')
            ),
            Positioned(
              right: 5,
              top: 30,
              child: SensorWindowButton('rightBicep')
            ),
            Positioned(
              left: 0,
              top: 60,
              child: SensorWindowButton('leftTricep')
            ),
            Positioned(
              right: 0,
              top: 60,
              child: SensorWindowButton('rightTricep')
            ),
            Positioned(
              left: 60,
              top: 70,
              child: SensorWindowButton('leftPect')
            ),
            Positioned(
              right: 60,
              top: 70,
              child: SensorWindowButton('rightPect')
            ),
            Positioned(
              left: 30,
              bottom: 60,
              child: SensorWindowButton('leftDelt')
            ),
            Positioned(
              right: 30,
              bottom: 60,
              child: SensorWindowButton('rightDelt')
            )
            //BigCard(pair: pair),
            //SizedBox(height: 10),
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     ElevatedButton.icon(
            //       onPressed: () {
            //         appState.toggleFavorite();
            //       },
            //       icon: Icon(icon),
            //       label: Text('Like'),
            //     ),
            //     SizedBox(width: 10),
            //     ElevatedButton(
            //       onPressed: () {
            //         appState.getNext();
            //       },
            //       child: Text('Next'),
            //     ),
            //   ],
            // ),
          ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty){
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
                "${appState.favorites.length} favorites:"),
        ),
        for (var fav in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(fav.asLowerCase),
          ),
      ],
    );
  }

}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, 
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}"),
      ),
    );
  }
}


