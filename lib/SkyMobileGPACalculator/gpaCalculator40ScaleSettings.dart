import 'package:flutter/material.dart';

class GPACalculatorSettings extends StatefulWidget {
  GPACalculatorSettings({Key key}) : super(key: key);

  @override
  _GPACalculatorSettingsState createState() =>
      _GPACalculatorSettingsState();
}

class _GPACalculatorSettingsState
    extends State<GPACalculatorSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: Text('4.0 Scale Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: ListView(
            children: <Widget>[
              Container(
                child: Text(
                  'Select the terms below that should count toward your final GPA.',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 20),
                ),
                padding: EdgeInsets.all(10),
              ),
            ],
          ),
        ));
  }
}
