import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skymobile/SkywardScraperAPI/SkywardAPITypes.dart';
import 'package:skymobile/SkyMobileHelperUtilities/globalVariables.dart';
import 'package:skymobile/SkyMobileHelperUtilities/customDialogOptions.dart';

class TermViewerPage extends StatefulWidget {
  MaterialColor secondColor;
  TermViewerPage({this.secondColor});
  @override
  _TermViewer createState() => new _TermViewer();
}

class _TermViewer extends State<TermViewerPage> {
  int currentTermIndex = 0;

  _goToGPACalculator(String courseName) async {
    bool isCancelled = false;
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled = true;
    }, title: 'Loading', description: ('Getting your grades..'));

    showDialog(context: context, builder: (BuildContext context) => dialog)
        .then((val) {
      isCancelled = true;
    });

    historyGrades = await skywardAPI.getHistory();
    if (!isCancelled) {
      Navigator.of(context, rootNavigator: true).popUntil((result) {
        return result.settings.name == '/termviewer';
      });
      Navigator.pushNamed(context, '/gpacalculatorschoolyear');
    }
  }

  _goToAssignmentsViewer(GradeBox gradeBox, String courseName) async {
    bool isCancelled = false;
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled = true;
    }, title: 'Loading', description: ('Getting your grades..'));

    showDialog(context: context, builder: (BuildContext context) => dialog)
        .then((val) {
      isCancelled = true;
    });

    assignmentsGridBoxes =
        await skywardAPI.getAssignmentsFromGradeBox(gradeBox);
    if (!isCancelled) {
      Navigator.of(context, rootNavigator: true).popUntil((result) {
        return result.settings.name == '/termviewer';
      });
      Navigator.pushNamed(context, '/assignmentsviewer');
    }
  }

  void initState() {
    super.initState();
    _setIntTerm();
  }

  _setIntTerm() {
    Term currentTerm;
    for (int i = 0; i < gradeBoxes.length; i++) {
      if (gradeBoxes[i] is GradeBox) {
        currentTerm = (gradeBoxes[i] as GradeBox).term;
      }
    }
    currentTermIndex = terms.indexOf(currentTerm);
    if (currentTermIndex < 0) currentTermIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: currentTermIndex);

    List<Widget> cupPickerWid = [];
    for (Term term in terms) {
      cupPickerWid.add(Container(
        child: Text('${term.termCode} / ${term.termName}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, color: Colors.white)),
        padding: EdgeInsets.only(top: 8),
      ));
    }

    List<Widget> body = [];

    for (int i = 0; i < gradeBoxes.length; i++) {
      if (gradeBoxes[i] is TeacherIDBox) {
        int indexOfTermGrade = -1;
        for (int j = i + 1; j < gradeBoxes.length; j++) {
          if (gradeBoxes[j] is GradeTextBox &&
              (gradeBoxes[j] as GradeTextBox).term == terms[currentTermIndex]) {
            indexOfTermGrade = j;
            break;
          }
          if (gradeBoxes[j] is TeacherIDBox) break;
        }
        TeacherIDBox teacherIDBox = gradeBoxes[i] as TeacherIDBox;
        GradeTextBox gradeBox;
        if (indexOfTermGrade != -1) {
          gradeBox = gradeBoxes[indexOfTermGrade] as GradeTextBox;
        }

        String grade = gradeBox != null
            ? (gradeBox is GradeBox)
                ? gradeBox.grade
                : (gradeBox as LessInfoBox).behavior
            : '';

        body.add(Card(
          child: InkWell(
              onTap: () {
                if (gradeBox != null && gradeBox is GradeBox)
                  _goToAssignmentsViewer(gradeBox, teacherIDBox.courseName);
              },
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
                              maxWidth:
                                  MediaQuery.of(context).size.width / 6 * 4),
                          padding: EdgeInsets.only(
                              top: 10, left: 10, right: 10, bottom: 0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            teacherIDBox.courseName,
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
                          padding: EdgeInsets.only(
                              top: 5, left: 10, right: 10, bottom: 0),
                          alignment: Alignment.centerLeft,
                          child: Text(teacherIDBox.teacherName,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.start),
                        ),
                        Container(
                            padding: EdgeInsets.only(
                                top: 5, left: 10, right: 10, bottom: 10),
                            alignment: Alignment.centerLeft,
                            child: Text(teacherIDBox.timePeriod,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                                textAlign: TextAlign.start))
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 60),
                    padding: EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    child: Text(
                      grade,
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: getColorFrom(grade)),
                    ),
                  ),
                ],
              )),
          color: Colors.white12,
        ));
      }
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: Text('Gradebook',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,)),
          actions: <Widget>[
            Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Colors.black87,
                ),
                child: PopupMenuButton(
                  onSelected: (String selected) {
                    switch (selected) {
                      case 'settings':
                        break;
                      case 'gpaCalc':
                        {
                          _goToGPACalculator('TEST');
                        }
                    }
                  },
                  itemBuilder: (_) => <PopupMenuItem<String>>[
                    PopupMenuItem<String>(
                        child: const Text(
                          'Settings',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'settings'),
                    PopupMenuItem<String>(
                        child: const Text(
                          'GPA Calculator',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'gpaCalc'),
                  ],
                ))
          ],
        ),
        backgroundColor: Colors.black,
        body: Center(
            child: Column(children: <Widget>[
          Container(
            child: InkWell(
              child: Card(
                color: Colors.orangeAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Container(
                  child: Text(
                    'Term: ${terms[currentTermIndex].termCode} / ${terms[currentTermIndex].termName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: body,
            ),
          )
        ])));
  }
}
