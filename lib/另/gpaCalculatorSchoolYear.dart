import 'package:flutter/material.dart';
import 'package:skymobile/globalVariables.dart';

class GPACalculatorSchoolYear extends StatefulWidget {
  MaterialColor secondColor;
  GPACalculatorSchoolYear({this.secondColor});
  @override
  _GPACalculatorSchoolYearState createState() =>
      new _GPACalculatorSchoolYearState();
}

class _GPACalculatorSchoolYearState extends State<GPACalculatorSchoolYear> {
  @override
  Widget build(BuildContext context) {
    bool didSuccessfullyGetOlderGrades = false;
    if (historyGrades != null) didSuccessfullyGetOlderGrades = true;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: Text('GPA Calculator',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 100),
                  child: Card(
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: Colors.white12,
                    child: SingleChildScrollView(
                      child: Row(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text("S1"),
                              Text("S1"),
                              Text("S1"),
                              Text("S1"),
                              Text("S1"),
                              Text("S1")
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                child: Text("GPA: "),
              )
            ],
          ),
        ));
  }
}
