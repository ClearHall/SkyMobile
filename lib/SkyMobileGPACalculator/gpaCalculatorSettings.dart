import 'package:flutter/material.dart';

class GPACalculatorSettings extends StatefulWidget {
  GPACalculatorSettings({Key key}) : super(key: key);

  @override
  _GPACalculatorSettingsState createState() => _GPACalculatorSettingsState();
}

class _GPACalculatorSettingsState extends State<GPACalculatorSettings> {
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
                  'Tick or change the settings depending on your district or college. Read descriptions carefully verify that the settings are correct.',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 20),
                ),
                padding: EdgeInsets.all(10),
              ),
              Container(
                width: double.infinity,
                child: Card(
                    child: Container(
                      child: Text(
                        "POP",
                        style: TextStyle(color: Colors.orange, fontSize: 20),
                      ),
                      padding: EdgeInsets.all(20),
                    ),
                    color: Colors.white12),
                padding:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
              )
            ],
          ),
        ));
  }

  //Widget _generateSettingsClickable(String setting, )
}
