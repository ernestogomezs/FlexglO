import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:provider/provider.dart';

import '/models/chartsdata.dart';

import '/utils/constants.dart';

import '/widgets/log_stopwatch.dart';
import '/widgets/charts_table.dart';

class LogPageScreen extends StatefulWidget{
  const LogPageScreen({Key? key}) : super(key: key);

  @override
  State<LogPageScreen> createState() => _LogPageState();
}

class _LogPageState extends State<LogPageScreen> {
  late String filename = '';

  @override
  initState(){
    super.initState();
  }

  Future<bool?> _raiseFilenameDialog() async{
    
    var nowTime = DateTime.now();
    String str = 'Session_from_${nowTime.month}-${nowTime.day}-${nowTime.year}';
    TextEditingController contr = TextEditingController(text: str);

    return showDialog<bool>(
      context: context,
      builder:(BuildContext context) { 
        return AlertDialog(
          title: const Text('Download File'),
          actions: <Widget>[
            TextFormField(
              controller: contr,
              decoration: const InputDecoration(
                icon: Icon(Icons.file_copy),
                labelText: 'Filename',
              )
            ),
            TextButton(
              onPressed: () => {
                filename = contr.text,
                Navigator.pop(context, true)
              },
              child: const Text('Save File'),
            ),
          ],
        );
      }
    );
  }

  String formatFile(){
    var chartsData = Provider.of<ChartsData>(context, listen: false);
    int numSteps = chartsData.elapsedTime.value.inMilliseconds~/CHART_TIMESTEP_MS;
    List<List<dynamic>> listofLists = [];

    List<dynamic> header = ['Time'];
    for(double i = 0; i < numSteps; i = i + 0.001){
      header.add(i.toStringAsPrecision(2));
    }
    listofLists.add(header);

    for(int i = 0; i < chartsData.charts.length; i++){
      listofLists.add(<dynamic>[chartsData.charts[i].muscle, ...chartsData.charts[i].data]);
    }

    return ListToCsvConverter().convert(listofLists);
  } 

  void _download() async{
    var raisedResult = await _raiseFilenameDialog();

    if (raisedResult == null) return;

    var file = formatFile();

    final result = 
      await Share.shareXFiles([XFile.fromData(utf8.encode(file), mimeType: 'text/plain')], 
        fileNameOverrides: ['$filename.csv']);

    if (result.status == ShareResultStatus.success) {
      //print('CHUPALOENTONCE');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ChartsTable(),
        const SizedBox(height: 20.0),
        LogStopwatch(
          _download
        ),
        const SizedBox(height: 60.0),
      ],
    );
  }
}