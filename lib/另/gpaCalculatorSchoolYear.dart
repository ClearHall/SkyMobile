import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/SkywardScraperAPI/SkywardAPITypes.dart';
import 'package:skymobile/globalVariables.dart';
import 'package:skymobile/辅助/alwaysVisibleScrollbar.dart';

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
    getHistGrades();
    getTermsToRead();
  }

  getHistGrades() async {
    historyGrades = await gpaCalculatorSettingsReadForCurrentSession();
    setState(() {});
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
    List<double> averages = getAveragesOfTermsCountingTowardGPA(enabledSchoolYears);

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
          child: ListView(
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
                padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: Card(
                      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Colors.white12,
                      child: SingleChildScrollViewWithScrollbar(
                        scrollbarColor: Colors.white30.withOpacity(0.75),
                        scrollbarThickness: 8.0,
                        child: SingleChildScrollView(
                            child: buildArrayOfSelectableTerms(
                                stringList)),
                      )),
                ),
              ),
              Container(
                child: Text(
                  'Hold a school year to modify its settings.',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 20),
                ),
                padding: EdgeInsets.all(20),
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 10.0),
                child: Container(
                    //padding: EdgeInsets.all(10.0),
                    // constraints: BoxConstraints(maxHeight: 100),
                    child: Card(
                        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: Colors.white12,
                        child: buildArrayOfSchoolYears())),
              ),
            ],
          ),
        ));
  }

  Column buildArrayOfSelectableTerms(List<String> stringList) {
    List<Widget> widgets = [];

    saveTermsToRead();
    for (String term in stringList) {
      if(!term.contains('\n'))
      widgets.add(Container(
        child: ListTile(
          title: Text(
            "$term",
            style: TextStyle(color: Colors.orange, fontSize: 20),
          ),
          trailing: IconButton(icon: Icon(
            termIdentifiersCountingTowardGPA.contains(term)
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: Colors.white),onPressed: () {
            setState(() {
              if(termIdentifiersCountingTowardGPA.contains(term)){
                termIdentifiersCountingTowardGPA.remove(term);
              }else{
                int index = stringList.indexOf(term);
                for(int i = 0; i < termIdentifiersCountingTowardGPA.length; i++){
                  if(stringList.indexOf(termIdentifiersCountingTowardGPA[i]) > index){
                    termIdentifiersCountingTowardGPA.insert(i, term);
                    break;
                  }
                }
                if(!termIdentifiersCountingTowardGPA.contains(term)) termIdentifiersCountingTowardGPA.add(term);
              }
            });
          },),
        ),
      ));
    }
    return Column(children: widgets,);
  }

  _checkTerms(List<String> selectableTerms){
    for(int i = termIdentifiersCountingTowardGPA.length - 1; i >= 0; i--){
      if(!selectableTerms.contains(termIdentifiersCountingTowardGPA[i])){
        termIdentifiersCountingTowardGPA.removeAt(i);
      }
    }
  }

  List<String> _getSelectableTermsString(List<SchoolYear> enabled) {
    List<Term> termlist = List.from(enabled.first.terms);
    List<String> stringList = [];
    for (int tI = 0; tI < termlist.length; tI++) {
      for (SchoolYear x in enabled) {
        if (!x.terms.contains(termlist[tI])) {
          termlist.removeAt(tI);
        }
      }
    }

    for (Term term in termlist) {
      stringList.add(term.termCode);
    }
    return stringList;
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
              color: Colors.black,
              child: InkWell(
                  onTap: () {
                    //TODO: IMPLEMENT ON TAP
                  },
                  child: ListTile(
                    title: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        "${i == 0 ? 'Current: ' : ''}${historyGrades[i].description}",
                        style: TextStyle(color: Colors.orange, fontSize: 20),
                      ),
                    ),
                    trailing: IconButton(
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
                          print("MAGIC");
                          setState(() {
                            historyGrades[i].isEnabled = true;
                          });
                        }
                      },
                    ),
                  )))));
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
