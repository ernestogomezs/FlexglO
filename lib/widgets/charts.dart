
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/chartsdata.dart';
import '/utils/constants.dart';

class Charts extends StatefulWidget{
  Charts(this.elapsedTime, {Key? key}) : super(key: key);

  final ValueNotifier<Duration> elapsedTime;

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts>{
  List<String> availableMuscles = MUSCLESITES;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TopBar(),
        SizedBox(
          height: 500,
          child: Consumer<ChartsData>(
            builder: (context, chartsData, child) {
              return Column(
                children: chartsData.charts
              );
            }
          ),
        ),
      ]
    );
  }
}

class TopBar extends StatefulWidget{
  TopBar({Key? key}) : super(key: key);

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar>{
  List<String> availableMuscles = List<String>.from(MUSCLESITES);
  
  @override
  initState(){
    super.initState();
  }

  void addPlot(String selectedMuscle) {
    if (availableMuscles.contains(selectedMuscle)) {
      Provider.of<ChartsData>(context, listen: false).addChart(selectedMuscle);
    }
    availableMuscles.remove(selectedMuscle);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: Theme.of(context).textTheme.headlineMedium!.fontSize! * 1.1+50,
      ),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8)
      ),
      child: OverflowBar(  
        textDirection: TextDirection.rtl,
        children: [
          DropdownButton<String>(
            items: availableMuscles.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            icon: Icon(
              Icons.add,
              color: Colors.grey[800]
            ),
            isExpanded: true,
            hint: Center(
              child: Text(
                "Select a muscle to record data",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[800]),
              )
            ),
            onChanged: (String? choice){
              addPlot(choice!);
            },
          )
        ],
      ),
    );
  }
}