import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/SupportWidgets/biometric_blur_view.dart';
import 'package:skymobile/ExtraViewPackages/hunty_dialogs.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skyscrapeapi/data_types.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import '../HelperUtilities/gpa_calculator_support_utils.dart';

class GPACalculatorSchoolYear extends StatefulWidget {
  GPACalculatorSchoolYear();
  @override
  GPACalculatorSchoolYearState createState() =>
      new GPACalculatorSchoolYearState();
}

class GPACalculatorSchoolYearState
    extends BiometricBlur<GPACalculatorSchoolYear> {
  @override
  void initState() {
    super.initState();

    getExtraGPASettings();
    if (historyGrades == null) historyGrades = [];
    _updateFirstInList(
        basedOn: historyGrades.length > 0 ? historyGrades.first : null);
  }

  _updateFirstInList({SchoolYear basedOn}) {
    SchoolYear first = SchoolYear();
    first.classes = [];
    first.description = 'Current Year';
    first.terms = terms;
    Class tmpClass;
    for (GridBox gridBox in gradeBoxes) {
      if (gridBox is TeacherIDBox) {
        if (tmpClass != null) first.classes.add(tmpClass);
        tmpClass = Class(gridBox.courseName);
        tmpClass.grades = List.filled(terms.length, "\n");
      } else if (gridBox is GradeBox) {
        tmpClass.grades[terms.indexOf(gridBox.term)] = (gridBox.grade);
      } else if (gridBox is LessInfoBox) {
        tmpClass.grades[terms.indexOf(gridBox.term)] = (gridBox.behavior);
      }
    }
    if (tmpClass != null) first.classes.add(tmpClass);
    if (historyGrades.length == 0) {
      historyGrades.add(first);
    } else {
      String name = historyGrades[0].description;
      first.description = name;
      historyGrades[0] = first;
    }

    if (basedOn != null &&
        basedOn == historyGrades[0] &&
        basedOn.classes.length == historyGrades[0].classes.length) {
      for (int i = 0; i < basedOn.classes.length; i++) {
        historyGrades[0].classes[i].classLevel = basedOn.classes[i].classLevel;
        historyGrades[0].classes[i].credits = basedOn.classes[i].credits;
      }
      historyGrades[0].isEnabled = basedOn.isEnabled;
    }
  }

  static List<SchoolYear> getEnabledHistGrades() {
    List<SchoolYear> fin = [];
    for (SchoolYear x in historyGrades) {
      if (x.isEnabled) fin.add(x);
    }
    return fin;
  }

  @override
  Widget generateBody(BuildContext context) {
//    bool didSuccessfullyGetOlderGrades = false;
    // _testGPACalcSaving();
//    if (historyGrades != null) didSuccessfullyGetOlderGrades = true
    List<SchoolYear> enabledSchoolYears = getEnabledHistGrades();
    List<String> stringList = getSelectableTermsString(enabledSchoolYears);
    _checkTerms(stringList);
//    List<double> averages =
//        getAveragesOfTermsCountingTowardGPA100PointScale(enabledSchoolYears);
    var finalGPA = get100GPA(enabledSchoolYears); //getFinalGPA(averages);
    var final40 = get40Scale(enabledSchoolYears);

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: themeManager.getColor(TypeOfWidget.text), size: 30),
          backgroundColor: themeManager.getColor(TypeOfWidget.background),
          title: Align(
              alignment: Alignment.center,
              child: Text(neiceban ? '内测版' : 'GPA Calculator',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: themeManager.getColor(TypeOfWidget.text),
                      fontSize: 25,
                      fontWeight: FontWeight.w700))),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: themeManager.getColor(TypeOfWidget.text),
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (bC) => HuntyDialogForMoreText(
                          title: 'Confused?',
                          description:
                              'The GPA Calculator contains many aspects. First, different districts use different TERMS to calculate your GPA. You should select the terms based on what your district uses. Note: Fort Bend ISD uses S1 and S2. Below the term selector, there is a school year selector. Choose which school years contain classes that count toward GPA. To modify the level of your classes in a school year, click the edit in each school year box. You may see your grades from that school year with the TERM Selector and you can also let SkyMobile autoselect levels for the classes. There is also a Deselect All button for convenience.\n4.0 Scale is based off of College Board scale.',
                          buttonText: 'Got it!',
                        ));
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              color: themeManager.getColor(TypeOfWidget.text),
              onPressed: () {
                Navigator.pushNamed(context, '/gpacalculatorsettings');
              },
            )
          ],
        ),
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        body: Center(
          child: Container(
            child: ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: themeManager.getColor(TypeOfWidget.subBackground),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "GPA: ${finalGPA.toString() != 'null' ? finalGPA.toStringAsFixed(5) : 'N/A'}",
                            style: TextStyle(
                                color: themeManager.getColor(TypeOfWidget.text),
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            "4.0 GPA: ${final40.toString() != 'null' ? final40.toStringAsFixed(5) : 'N/A'}",
                            style: TextStyle(
                                color: themeManager.getColor(TypeOfWidget.text),
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
//              Row(children: <Widget>[
//                Expanded(
//                  child: Container(
//                    padding: EdgeInsets.only(top: 10, left: 20, right: 0),
//                    child: Card(
//                        shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(15)),
//                        child: buildGradeDisplayWidget(
//                            '100 Point', getFinalGPA(averages), bold: true),
//                        color:
//                            themeManager.getColor(TypeOfWidget.subBackground)),
//                  ),
//                ),
//                Expanded(
//                  child: Container(
//                    padding: EdgeInsets.only(top: 10, left: 0, right: 20),
//                    child: Card(
//                        child: buildGradeDisplayWidget(
//                            '4.0 Scale', get40Scale(enabledSchoolYears),
//                            bold: true),
//                        color:
//                            themeManager.getColor(TypeOfWidget.subBackground)),
//                  ),
//                )
//              ]),
//                Container(
//                  padding: EdgeInsets.only(
//                      top: termIdentifiersCountingTowardGPA.isEmpty ? 0 : 10,
//                      left: 20,
//                      right: 20),
//                  child: buildBasedOnTwo(averages),
//                ),
//                Container(
//                  padding: EdgeInsets.only(
//                      top: termIdentifiersCountingTowardGPA.isEmpty ? 0 : 10,
//                      left: 20,
//                      right: 20),
//                  child: ConstrainedBox(
//                    constraints: BoxConstraints(maxHeight: 100),
//                    child: Card(
//                        shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(20)),
//                        color:
//                            themeManager.getColor(TypeOfWidget.subBackground),
//                        child: SingleChildScrollViewWithScrollbar(
//                          scrollbarColor: Colors.white30.withOpacity(0.75),
//                          scrollbarThickness: 8.0,
//                          child: SingleChildScrollView(
//                              child: Container(
//                                  padding: EdgeInsets.only(right: 20, left: 20),
//                                  child: buildArrayOfTermAverageWidgets(
//                                      averages))),
//                        )),
//                  ),
//                ),
//              Container(
//                child: Text(
//                  'If your district shows your GPA in portfolio, then your GPA in portfolio is most likely without the current year.',
//                  style: TextStyle(
//                      color: themeManager.getColor(TypeOfWidget.text),
//                      fontSize: 20),
//                ),
//                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
//              ),
//              Container(
//                child: Text(
//                  'Select the terms below that should count toward your final GPA.',
//                  style: TextStyle(
//                      color: themeManager.getColor(TypeOfWidget.text),
//                      fontSize: 20),
//                ),
//                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
//              ),
                Container(
                  child: Text(
                    'Add/Edit School Years',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                        color: themeManager.getColor(TypeOfWidget.text),
                        fontSize: 20),
                  ),
                  padding: EdgeInsets.only(top: 20, left: 35, right: 35, bottom: 5),
                ),
                Container(
                  padding: EdgeInsets.only(
                      top: 0, left: 20, right: 20, bottom: 10.0),
                  child: Container(
                      //padding: EdgeInsets.all(10.0),
                          child: buildArrayOfSchoolYears()),
                ),
              ],
            ),
          ),
        ));
  }

  _checkTerms(List<String> selectableTerms) {
    for (int i = termIdentifiersCountingTowardGPA.length - 1; i >= 0; i--) {
      if (!selectableTerms.contains(termIdentifiersCountingTowardGPA[i])) {
        termIdentifiersCountingTowardGPA.removeAt(i);
      }
    }
  }

  static List<String> getSelectableTermsString(List<SchoolYear> enabled) {
    LinkedHashSet<Term> termList = LinkedHashSet<Term>();

    for (SchoolYear year in enabled) {
      termList.addAll(year.terms);
    }

    return List.generate(
        termList.length, (ind) => termList.elementAt(ind).termCode);
  }

  Column buildArrayOfSchoolYears() {
    List<Widget> widgets = [];
    for (int i = 0; i < historyGrades.length; i++) {
      widgets.add(Container(
          padding: EdgeInsets.only(
              top: 5.0,
              bottom: i == historyGrades.length - 1 ? 5 : 0),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color: themeManager.getColor(TypeOfWidget.subBackground),
              child: ListTile(
                  title: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      "${i == 0 ? 'Current: ' : ''}${historyGrades[i].description}",
                      style: TextStyle(
                          color: themeManager.getColor(TypeOfWidget.text),
                          fontSize: 20),
                    ),
                  ),
                  trailing:
                      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    IconButton(
                      icon: Icon(
                          historyGrades[i].isEnabled
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: themeManager.getColor(null)),
                      onPressed: () {
                        if (_checkIfShouldBeDisabled())
                          setState(() {
                            historyGrades[i].isEnabled =
                                !historyGrades[i].isEnabled;
                            gpaCalculatorSettingsSaveForCurrentSession();
                          });
                        else {
                          setState(() {
                            historyGrades[i].isEnabled = true;
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: themeManager.getColor(null)),
                      onPressed: () {
                        Navigator.pushNamed(context, '/gpacalculatorclasses',
                            arguments: historyGrades[i]);
                      },
                    ),
                  ])))));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  bool _checkIfShouldBeDisabled() {
    int enabled = 0;
    for (SchoolYear x in historyGrades) {
      if (x.isEnabled) enabled++;
    }
    if (enabled == 1) return false;
    if (enabled <= 0) {
      if (historyGrades.length > 0) historyGrades.first.isEnabled = true;
      return false;
    }
    return true;
  }

  double getFinalGPA(List<double> averages) {
    int avgLen = averages.length;
    return averages.fold(0, (v, e) {
          if (e == null)
            avgLen--;
          else
            return v + e;
          return v;
        }) /
        avgLen;
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

  Column buildBasedOnTwo(List<double> grades){
    List<Widget> widgets = [];
    for (int i = 0; i < grades.length; i += 2) {
        widgets.add(Row(children: <Widget>[Flexible(child: _generateMiniCard(grades, i)),
          (grades.length > i + 1) ? Flexible(child: _generateMiniCard(grades, i + 1)) : Container()
        ]));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Card _generateMiniCard(List<double> grades, int index){
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: themeManager.getColor(TypeOfWidget.subBackground),
        child: buildGradeDisplayWidget(
            termIdentifiersCountingTowardGPA[index], grades[index], align: TextAlign.center));
  }

  Widget buildGradeDisplayWidget(String term, double grade,
      {Color colorOverride, bool bold = false, TextAlign align = TextAlign.left}) {
    return Container(
      width: double.infinity,
      child: Text(
        "$term: ${grade.toString() != 'null' ? grade.toStringAsFixed(3) : 'N/A'}",
        style: TextStyle(
            color: colorOverride ?? themeManager.getColor(TypeOfWidget.text),
            fontSize: 20,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal),
      textAlign: align,),
      padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
    );
  }
}
