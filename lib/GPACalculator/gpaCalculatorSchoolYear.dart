import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/HelperUtilities/customDialogOptions.dart';
import 'package:skymobile/HelperUtilities/themeColorManager.dart';
import 'package:skyscrapeapi/skywardAPITypes.dart';
import 'package:skymobile/HelperUtilities/globalVariables.dart';
import 'package:skymobile/HelperUtilities/alwaysVisibleScrollbar.dart';
import 'gpaCalculatorSupportUtils.dart';

class GPACalculatorSchoolYear extends StatefulWidget {
  MaterialColor secondColor;
  GPACalculatorSchoolYear({this.secondColor});
  @override
  _GPACalculatorSchoolYearState createState() =>
      new _GPACalculatorSchoolYearState();
}

class _GPACalculatorSchoolYearState extends State<GPACalculatorSchoolYear> {
  @override
  void initState() {
    super.initState();

    getExtraGPASettings();
    if (historyGrades == null) historyGrades = [];
    _updateFirstInList(basedOn: historyGrades.length > 0 ? historyGrades.first : null);
  }

  _updateFirstInList({SchoolYear basedOn}){
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

    if(basedOn != null && basedOn == historyGrades[0] && basedOn.classes.length == historyGrades[0].classes.length){
      for(int i = 0; i < basedOn.classes.length; i++){
        historyGrades[0].classes[i].classLevel = basedOn.classes[i].classLevel;
        historyGrades[0].classes[i].credits = basedOn.classes[i].credits;
      }
      historyGrades[0].isEnabled = basedOn.isEnabled;
    }
  }

  List<SchoolYear> getEnabledHistGrades() {
    List<SchoolYear> fin = [];
    for (SchoolYear x in historyGrades) {
      if (x.isEnabled) fin.add(x);
    }
    return fin;
  }

  @override
  Widget build(BuildContext context) {
//    bool didSuccessfullyGetOlderGrades = false;
    // _testGPACalcSaving();
//    if (historyGrades != null) didSuccessfullyGetOlderGrades = true
    List<SchoolYear> enabledSchoolYears = getEnabledHistGrades();
    List<String> stringList = _getSelectableTermsString(enabledSchoolYears);
    _checkTerms(stringList);
    List<double> averages =
        getAveragesOfTermsCountingTowardGPA100PointScale(enabledSchoolYears);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: themeManager.getColor(TypeOfWidget.button),
          title: Text('GPA Calculator',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Colors.black,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (bC) => HuntyDialogForMoreText(
                          title: 'Confused?',
                          description:
                              'The GPA Calculator contains many aspects. First, different districts use different TERMS to calculate your GPA. You should select the terms based on what your district uses. Note: Fort Bend ISD uses S1 and S2. Below the term selector, there is a school year selector. Choose which school years contain classes that count toward GPA. To modify the level of your classes in a school year, click the arrow in each school year box. You may see your grades from that school year with the TERM Selector and you can also let SkyMobile autoselect levels for the classes. There is also a Deselect All button for convenience.\n4.0 Scale is based off of College Board scale.',
                          buttonText: 'Got it!',
                        ));
              },
            )
          ],
        ),
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        body: Center(
          child: ListView(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Card(
                      color: themeManager.getColor(TypeOfWidget.subBackground),
                      child: InkWell(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'GPA Calculator Settings',
                            style:
                                TextStyle(color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/gpacalculatorsettings');
                        },
                      ))),
              Container(
                padding: EdgeInsets.only(
                    top: termIdentifiersCountingTowardGPA.isEmpty ? 0 : 10,
                    left: 20,
                    right: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 100),
                  child: Card(
                      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: themeManager.getColor(TypeOfWidget.subBackground),
                      child: SingleChildScrollViewWithScrollbar(
                        scrollbarColor: Colors.white30.withOpacity(0.75),
                        scrollbarThickness: 8.0,
                        child: SingleChildScrollView(
                            child: buildArrayOfTermAverageWidgets(averages)),
                      )),
                ),
              ),
              Container(
                child: Text(
                  'If your district shows your GPA in portfolio, then your GPA in portfolio is most likely without the current year.',
                  style: TextStyle(color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
                ),
                padding: EdgeInsets.all(10),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Card(
                    child:
                        buildGradeDisplayWidget('GPA', getFinalGPA(averages)),
                    color: themeManager.getColor(TypeOfWidget.subBackground)),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Card(
                    child: buildGradeDisplayWidget(
                        '4.0 GPA', get40Scale(enabledSchoolYears)),
                    color: themeManager.getColor(TypeOfWidget.subBackground)),
              ),
              Container(
                child: Text(
                  'Select the terms below that should count toward your final GPA.',
                  style: TextStyle(color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
                ),
                padding: EdgeInsets.all(10),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: Card(
                      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: themeManager.getColor(TypeOfWidget.subBackground),
                      child: SingleChildScrollViewWithScrollbar(
                        scrollbarColor: Colors.white30.withOpacity(0.75),
                        scrollbarThickness: 8.0,
                        child: SingleChildScrollView(
                            child: buildArrayOfSelectableTerms(stringList)),
                      )),
                ),
              ),
              Container(
                child: Text(
                  'Select which school years count toward final GPA below. To modify which classes count toward GPA, click the arrow.',
                  style: TextStyle(color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
                ),
                padding: EdgeInsets.all(10),
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 10.0),
                child: Container(
                    //padding: EdgeInsets.all(10.0),
                    // constraints: BoxConstraints(maxHeight: 100),
                    child: Card(
                        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: themeManager.getColor(TypeOfWidget.subBackground),
                        child: buildArrayOfSchoolYears())),
              ),
            ],
          ),
        ));
  }

  Column buildArrayOfSelectableTerms(List<String> stringList) {
    List<Widget> widgets = [];

    for (String term in stringList) {
      if (!term.contains('\n'))
        widgets.add(Container(
          child: ListTile(
            title: Text(
              "$term",
              style: TextStyle(color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
            ),
            trailing: IconButton(
              icon: Icon(
                  termIdentifiersCountingTowardGPA.contains(term)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Colors.white),
              onPressed: () {
                setState(() {
                  if (termIdentifiersCountingTowardGPA.contains(term)) {
                    termIdentifiersCountingTowardGPA.remove(term);
                  } else {
                    int index = stringList.indexOf(term);
                    for (int i = 0;
                        i < termIdentifiersCountingTowardGPA.length;
                        i++) {
                      if (stringList
                              .indexOf(termIdentifiersCountingTowardGPA[i]) >
                          index) {
                        termIdentifiersCountingTowardGPA.insert(i, term);
                        break;
                      }
                    }
                    if (!termIdentifiersCountingTowardGPA.contains(term))
                      termIdentifiersCountingTowardGPA.add(term);
                  }
                  saveTermsToRead();
                });
              },
            ),
          ),
        ));
    }
    return Column(
      children: widgets,
    );
  }

  _checkTerms(List<String> selectableTerms) {
    for (int i = termIdentifiersCountingTowardGPA.length - 1; i >= 0; i--) {
      if (!selectableTerms.contains(termIdentifiersCountingTowardGPA[i])) {
        termIdentifiersCountingTowardGPA.removeAt(i);
      }
    }
  }

  List<String> _getSelectableTermsString(List<SchoolYear> enabled) {
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
              left: 5,
              right: 5,
              top: 5.0,
              bottom: i == historyGrades.length - 1 ? 5 : 0),
          child: Card(
              color: themeManager.getColor(TypeOfWidget.background),
              child: ListTile(
                  title: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      "${i == 0 ? 'Current: ' : ''}${historyGrades[i].description}",
                      style: TextStyle(color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
                    ),
                  ),
                  trailing:
                      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    IconButton(
                      icon: Icon(
                          historyGrades[i].isEnabled
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.white),
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
                      icon: Icon(Icons.play_circle_filled, color: Colors.white),
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

  Widget buildGradeDisplayWidget(String term, double grade) {
    return Container(
      width: double.infinity,
      child: Text(
        "$term: ${grade.toString() != 'null' ? grade.toString() : 'N/A'}",
        style: TextStyle(color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
      ),
      padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
    );
  }
}
