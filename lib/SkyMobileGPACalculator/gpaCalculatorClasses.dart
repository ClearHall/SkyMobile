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

  GPACalculatorClassesState(this.schoolYear);

  @override
  void initState() {
    super.initState();
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
            Container(
              child: InkWell(
                child: Card(
                  color: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Container(
                    child: Text(
                      'Term: ${schoolYear.terms[currentTermIndex + offset].termCode} / ${schoolYear.terms[currentTermIndex + offset].termName}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
              padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            ),
          ],
        )));
  }

  List<Widget> buildArrayOfClasses(){
    List<Widget> fin = [];

    for(Class schoolClass in schoolYear.classes){
      //fin.add();
    }

    return fin;
  }
}
