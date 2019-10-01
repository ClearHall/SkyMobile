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
  int currentTermIndex = 0;
  int offset = 0;
  SchoolYear schoolYear;
  final availableClassLevels = ClassLevel.values;
  final List<double> availableCredits = [];
  List<int> dropDownIndexesClassLevel;
  List<int> dropDownIndexesCredits;

  GPACalculatorClassesState(this.schoolYear);

  @override
  void initState() {
    super.initState();

    for(int i = 1; i <= 6; i++){
      availableCredits.add(0.5 * i);
    }

    dropDownIndexesClassLevel = List.generate(schoolYear.classes.length, (int ind) {
      return availableClassLevels
          .indexOf(schoolYear.classes[ind].classLevel ?? ClassLevel.Regular);
    });
    dropDownIndexesCredits = List.generate(schoolYear.classes.length, (int ind) {
      double credits = schoolYear.classes[ind].credits ?? 1.0;
      return availableCredits
          .indexOf(credits / 0.5 <= 6.0 && credits / 0.5 >= 0 ? credits : 1.0);
    });
  }

  void setDropDown() {
    for (int i = 0; i < schoolYear.classes.length; i++) {
      schoolYear.classes[i].classLevel =
          availableClassLevels[dropDownIndexesClassLevel[i]];
    }
    for (int i = 0; i < schoolYear.classes.length; i++) {
      schoolYear.classes[i].credits =
      availableCredits[dropDownIndexesCredits[i]];
    }
    gpaCalculatorSettingsSaveForCurrentSession();
  }

  @override
  Widget build(BuildContext context) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: currentTermIndex);

    //TODO: MAKE TERM SELECTOR A STATEFUL OBJECT

    List<Widget> cupPickerWid = [];
    offset = 0;
    for (Term term in schoolYear.terms) {
      if (!term.termCode.contains('\n'))
        cupPickerWid.add(Container(
          child: Text('${term.termCode} / ${term.termName}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, color: Colors.white)),
          padding: EdgeInsets.only(top: 8),
        ));
      else {
        offset++;
      }
    }

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
            child: Column(
          children: <Widget>[
            Row(mainAxisSize: MainAxisSize.min,children: <Widget>[
              Expanded(child: Container(
                child: InkWell(
                  child: Card(
                    color: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: Container(
                      child: Text(
                        'Term: ${schoolYear.terms[currentTermIndex + offset].termCode}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      padding: EdgeInsets.all(20),
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) => CupertinoPicker(
                            scrollController: scrollController,
                            backgroundColor: Colors.black,
                            children: cupPickerWid,
                            itemExtent: 50,
                            onSelectedItemChanged: (int changeTo) {
                              setState(() {
                                currentTermIndex = changeTo;
                              });
                            }));
                  },
                ),
                padding: EdgeInsets.only(top: 10, left: 10, right: 5),
              ),),
              Expanded(child: Container(
                child: InkWell(
                  child: Card(
                    color: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: Container(
                      child: Text(
                        'Predict Class',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      padding: EdgeInsets.all(20),
                    ),
                  ),
                  onTap: () {
                    for(Class classYear in schoolYear.classes){
                      String courseName = classYear.name;
                      if(courseName.contains('PreA') || courseName.contains('Honor'))
                        classYear.classLevel = ClassLevel.PreAP;
                      else if(courseName.contains('AP'))
                        classYear.classLevel = ClassLevel.AP;
                      else
                        classYear.classLevel = ClassLevel.Regular;
                      dropDownIndexesClassLevel[schoolYear.classes.indexOf(classYear)] = availableClassLevels.indexOf(classYear.classLevel);
                    }
                    setState(() {
                      gpaCalculatorSettingsSaveForCurrentSession();
                    });
                  },
                ),
                padding: EdgeInsets.only(top: 10, left: 0, right: 5),
              )),
            ]),
            Expanded(
              child: ListView(
                children: buildArrayOfClasses(currentTermIndex + offset),
              ),
            ),
          ],
        )));
  }

  List<Widget> buildArrayOfClasses(int indexOfTermWithOffset) {
    List<Widget> fin = [];

    for (Class schoolClass in schoolYear.classes) {
      fin.add(Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 6 * 4),
                    padding: EdgeInsets.only(
                        top: 10, left: 15, right: 10, bottom: 0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      schoolClass.name.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 15, top: 5),
                      child: Theme(
                          data: Theme.of(context)
                              .copyWith(canvasColor: Colors.black),
                          child: DropdownButton<String>(
                            items: availableClassLevels
                                .map<DropdownMenuItem<String>>(
                                    (ClassLevel value) {
                              return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(
                                  value.toString().substring(11),
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            value: availableClassLevels[dropDownIndexesClassLevel[
                                    schoolYear.classes.indexOf(schoolClass)]]
                                .toString(),
                            onChanged: (String newVal) {
                              setState(() {
                                dropDownIndexesClassLevel[schoolYear.classes
                                        .indexOf(schoolClass)] =
                                    availableClassLevels.indexOf(
                                        ClassLevel.values.firstWhere(
                                            (e) => e.toString() == newVal));
                                setDropDown();
                              });
                            },
                          ))),Container(
                      padding: EdgeInsets.only(left: 15, bottom: 10),
                      child: Theme(
                          data: Theme.of(context)
                              .copyWith(canvasColor: Colors.black),
                          child: DropdownButton<String>(
                            items: availableCredits
                                .map<DropdownMenuItem<String>>(
                                    (double value) {
                                  return DropdownMenuItem<String>(
                                    value: value.toString(),
                                    child: Text(
                                      value.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                            value: availableCredits[dropDownIndexesCredits[
                            schoolYear.classes.indexOf(schoolClass)]]
                                .toString(),
                            onChanged: (String newVal) {
                              setState(() {
                                dropDownIndexesCredits[schoolYear.classes
                                    .indexOf(schoolClass)] = availableCredits.indexOf(double.tryParse(newVal) ?? 1.0);
                                setDropDown();
                              });
                            },
                          )))
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(minHeight: 60),
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.centerRight,
              child: Text(
                schoolClass.grades[indexOfTermWithOffset].trim(),
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: getColorFrom(
                        schoolClass.grades[indexOfTermWithOffset].trim())),
              ),
            ),
          ],
        ),
        color: Colors.white12,
      ));
    }

    return fin;
  }
}
