import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/SkywardScraperAPI/SkywardAPITypes.dart';
import 'package:skymobile/SkyMobileHelperUtilities/globalVariables.dart';
import 'gpaCalculatorSupportUtils.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text(schoolYear.description,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w700)),
      ),
    backgroundColor: Colors.black,
    body: Center(

    )
    );
  }
}