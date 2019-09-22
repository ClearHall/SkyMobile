import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/SkywardScraperAPI/SkywardAPITypes.dart';
import 'package:skymobile/globalVariables.dart';
import 'package:skymobile/辅助/jsonSaver.dart';
import 'package:skymobile/辅助/alwaysVisibleScrollbar.dart';

class GPACalculatorSchoolYear extends StatefulWidget {
  MaterialColor secondColor;
  GPACalculatorSchoolYear({this.secondColor});
  @override
  _GPACalculatorSchoolYearState createState() =>
      new _GPACalculatorSchoolYearState();
}

class _GPACalculatorSchoolYearState extends State<GPACalculatorSchoolYear> {
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.gpaCalcAttributes);

  _testGPACalcSaving() async {
    await jsonSaver.saveListData(historyGrades);
    List<SchoolYear> data =
        List<SchoolYear>.from(await jsonSaver.readListData());
    List<SchoolYear> newDat = [data[1]];
    print(getAveragesOfTermsCountingTowardGPA(newDat));
  }

  @override
  Widget build(BuildContext context) {
//    bool didSuccessfullyGetOlderGrades = false;
    _testGPACalcSaving();
//    if (historyGrades != null) didSuccessfullyGetOlderGrades = true;

    //DEBUGGING USE
    List<SchoolYear> newDat = [historyGrades[1]];
    List<double> averages = getAveragesOfTermsCountingTowardGPA(newDat);

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
                      child: SingleChildScrollViewWithScrollbar(
                        scrollbarColor: Colors.white30.withOpacity(0.75),
                        scrollbarThickness: 8.0,
                        child: SingleChildScrollView(
                            child: buildArrayOfTermAverageWidgets(averages)),
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Card(
                    child:
                        buildGradeDisplayWidget('GPA', getFinalGPA(averages)),
                    color: Colors.white12),
              ),
              Container(
                child: Text(
                  'Click any school year to modify the classes inside.',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 20),
                ),
                padding: EdgeInsets.all(18),
              )
            ],
          ),
        ));
  }

  double getFinalGPA(List<double> averages) {
    return averages.fold(0, (v, e) => v + e) / averages.length;
  }

  Column buildArrayOfTermAverageWidgets(List<double> grades) {
    List<Widget> widgets = [];
    for (int i = 0; i < grades.length; i++) {
      if (termIdentifiersCountingTowardGPA.length > i && grades.length > i)
        widgets.add(Flexible(
            child: buildGradeDisplayWidget(
                termIdentifiersCountingTowardGPA[i], grades[i])));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget buildGradeDisplayWidget(String term, double grade) {
    return Container(
      width: double.infinity,
      child: Text(
        "$term: ${grade.toString()}",
        style: TextStyle(color: Colors.orange, fontSize: 20),
      ),
      padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
    );
  }
}
