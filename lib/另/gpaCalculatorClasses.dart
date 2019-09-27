import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/SkywardScraperAPI/SkywardAPITypes.dart';
import 'package:skymobile/globalVariables.dart';
import 'package:skymobile/辅助/alwaysVisibleScrollbar.dart';

class GPACalculatorClasses extends StatefulWidget {
  MaterialColor secondColor;
  SchoolYear schoolYear;
  GPACalculatorClasses(this.schoolYear, {this.secondColor});
  @override
  GPACalculatorClassesState createState() =>
      new GPACalculatorClassesState(this.schoolYear);
}

class GPACalculatorClassesState extends State<GPACalculatorClasses> {
  SchoolYear schoolYear;

  @override
  void initState() {
    super.initState();
  }

  GPACalculatorClassesState(this.schoolYear);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       );
  }
}