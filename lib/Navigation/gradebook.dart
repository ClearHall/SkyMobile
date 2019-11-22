import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skymobile/ExtraViewPackages/biometric_blur_view.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skyscrapeapi/data_types.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/ExtraViewPackages/hunty_dialogs.dart';
import 'package:skymobile/HelperUtilities/gpa_calculator_support_utils.dart';

class TermViewerPage extends StatefulWidget {
  TermViewerPage();
  @override
  _TermViewer createState() => new _TermViewer();
}

class _TermViewer extends BiometricBlur<TermViewerPage> {
  int currentTermIndex = 0;

  @override
  void initState() {
    super.initState();
    _setIntTerm();
    _retrieveMessagesInTheBackground();
  }

  _retrieveMessagesInTheBackground() async {
    messages = await skywardAPI.getMessages();
    for (Message m in messages) print(m);
  }

  _goToGPACalculator() async {
    bool isCancelled = false;
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled = true;
    }, title: 'Loading', description: ('Getting your grades..'));

    showDialog(context: context, builder: (BuildContext context) => dialog)
        .then((val) {
      isCancelled = true;
    });

    try {
      var result = await skywardAPI.getHistory();
      historyGrades = result;
    } catch (e) {
      Navigator.of(context).pop(dialog);
      String errMsg =
          'An error occured, please contact the developer: ${e.toString()}';

      showDialog(
          context: context,
          builder: (buildContext) {
            return HuntyDialog(
                title: 'Uh Oh', description: errMsg, buttonText: 'Ok');
          });
      isCancelled = true;
    }

    if (!isCancelled) {
      historyGrades = await gpaCalculatorSettingsReadForCurrentSession();
      await getTermsToRead();
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

    try {
      var result = await skywardAPI.getAssignmentsFromGradeBox(gradeBox);
      assignmentsGridBoxes = result;
    } catch (e, s) {
      Navigator.of(context).pop(dialog);
      String errMsg =
          'An error occured, please contact the developer: ${e.toString()}';

      print(s);

      showDialog(
          context: context,
          builder: (buildContext) {
            return HuntyDialog(
                title: 'Uh Oh', description: errMsg, buttonText: 'Ok');
          });
      isCancelled = true;
    }

    if (!isCancelled) {
      Navigator.of(context, rootNavigator: true).popUntil((result) {
        return result.settings.name == '/termviewer';
      });
      Navigator.pushNamed(context, '/assignmentsviewer');
    }
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

//  _showChildrenChangeDialog() async {
//    List newList = [];
//    if (skywardAPI.children != null) {
//      for (SkywardAccount s in skywardAPI.children) {
//        newList.add(s.name);
//      }
//    }
//    if (newList.length >= 1) newList.removeAt(0);
//
//    bool isCancelled = true;
//    var dialog = HuntyDialogOfList(
//      hint: null,
//      listOfValues: newList,
//      title: 'Children',
//      description: 'Choose which child\'s grades you would like to view.',
//      buttonText: 'Enter',
//      okPressed: () {
//        isCancelled = false;
//      },
//    );
//
//    await showDialog(context: context, builder: (bc) => dialog);
//
//    if (!isCancelled) {
//      _submitAndChangeChild(dialog.indexOfValueChosen + 1);
//    }
//  }

  _submitAndChangeChild(int ind) async {
    skywardAPI.switchUserIndex(ind);

    var dialog1 = HuntyDialogLoading('Cancel', () {},
        title: 'Loading', description: ('Getting your grades..'));

    dialog1.restrictCancel = true;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => dialog1);

    try {
      var termRes = await skywardAPI.getGradeBookTerms();
      var gradebookRes = (await skywardAPI.getGradeBookGrades(termRes));

      setState(() {
        terms = termRes;
        gradeBoxes = gradebookRes;

        Navigator.of(context, rootNavigator: true).popUntil((result) {
          return result.settings.name == '/termviewer';
        });
      });
    } catch (e) {
      print(e);
      Navigator.of(context).pop(dialog1);
      await showDialog(
          context: context,
          builder: (_) {
            return HuntyDialog(
                title: 'Oh No!',
                description:
                    'An error occured and we could not get your grades. Please report this to a developer! An error occured while parsing your grades.',
                buttonText: 'Ok');
          });
    }
  }

  bool expanded = false;

  @override
  Widget generateBody(BuildContext context) {
    currentChild = skywardAPI.retrieveAccountIfParent()?.dataID;
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
              borderRadius: BorderRadius.circular(10),
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
                              top: 10, left: 15, right: 10, bottom: 0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            teacherIDBox.courseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: themeManager.getColor(TypeOfWidget.text),
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              top: 5, left: 15, right: 10, bottom: 0),
                          alignment: Alignment.centerLeft,
                          child: Text(teacherIDBox.teacherName,
                              style: TextStyle(
                                  color: themeManager.getColor(null),
                                  fontSize: 15),
                              textAlign: TextAlign.start),
                        ),
                        Container(
                            padding: EdgeInsets.only(
                                top: 5, left: 15, right: 10, bottom: 10),
                            alignment: Alignment.centerLeft,
                            child: Text(teacherIDBox.timePeriod,
                                style: TextStyle(
                                    color: themeManager.getColor(null),
                                    fontSize: 15),
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
          color: themeManager.getColor(TypeOfWidget.subBackground),
        ));
      }
    }

    List<Widget> drawerWidgets = [
      DrawerHeader(
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            skywardAPI.currentUser,
            style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text),
            ),
          ),
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.settings,
          color: themeManager.getColor(TypeOfWidget.text),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text), fontSize: 25),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/settings');
        },
      ),
      ListTile(
        leading: Icon(
          Icons.assessment,
          color: themeManager.getColor(TypeOfWidget.text),
        ),
        title: Text(
          'GPA Calculator',
          style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text), fontSize: 25),
        ),
        onTap: () {
          _goToGPACalculator();
        },
      ),
      skywardAPI.children != null
          ? ListTile(
              leading: Icon(
                expanded ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                color: themeManager.getColor(TypeOfWidget.text),
              ),
              title: Text(
                'Change Child',
                style: TextStyle(
                    color: themeManager.getColor(TypeOfWidget.text),
                    fontSize: 25),
              ),
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },
            )
          : Container(),
//      SkyVars.getVar('version') >= 3
//          ? ListTile(
//              leading: Icon(Icons.message,
//                  color: themeManager.getColor(TypeOfWidget.text)),
//              title: Text(
//                'Messages',
//                style: TextStyle(
//                    color: themeManager.getColor(TypeOfWidget.text),
//                    fontSize: 25),
//              ),
//              onTap: () {
//                if (messages == null) {
//                  showDialog(
//                      context: context,
//                      builder: (b) => HuntyDialog(
//                          title: 'Uh-Oh',
//                          description:
//                              ('Messages hasn\'t finished loading yet. Please wait'),
//                          buttonText: 'Ok'));
//                } else {
//                  Navigator.pushNamed(context, '/messages');
//                }
//              },
//            )
//          : Container(),
      ListTile(
        leading: Icon(
          Icons.arrow_back,
          color: themeManager.getColor(TypeOfWidget.text),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text), fontSize: 25),
        ),
        onTap: () {
          messages = null;
          gradeBoxes = null;
          terms = null;
          Navigator.popUntil(context, (pred) {
            return pred.settings.name == '/';
          });
        },
      ),
    ];

    List children = [];
    if (skywardAPI.children != null && skywardAPI.children.isNotEmpty) {
      children = List.from(skywardAPI.children);
      children.removeAt(0);
    }
    for (int i = 0; i < drawerWidgets.length; i++) {
      if (drawerWidgets[i] is ListTile &&
          expanded &&
          ((drawerWidgets[i] as ListTile).title as Text).data ==
              'Change Child') {
        for (int j = 0; j < children.length; j++) {
          drawerWidgets.insert(
              i + 1,
              ListTile(
                leading: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.person,
                    color: themeManager.getColor(TypeOfWidget.text),
                  ),
                ]),
                title: Text(
                  children[j].name,
                  style: TextStyle(
                      color: themeManager.getColor(TypeOfWidget.text),
                      fontSize: 25),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _submitAndChangeChild(j + 1);
                },
              ));
        }
        break;
      }
    }

    return Scaffold(
      drawer: Theme(
        data: Theme.of(context).copyWith(
            canvasColor: themeManager.getColor(TypeOfWidget.background)),
        child: Drawer(
          child: ListView(children: drawerWidgets),
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: themeManager.getColor(TypeOfWidget.text), size: 30),
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        title: Align(
            alignment: Alignment.center,
            child: Text('Gradebook',
                style: TextStyle(
                  color: themeManager.getColor(TypeOfWidget.text),
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ))),
        actions: <Widget>[
          SizedBox(
            width: 50,
          )
        ],
//          IconButton(
//            icon: Icon(
//              Icons.arrow_back,
//              color: themeManager.getColor(TypeOfWidget.text),
//            ),
//            onPressed: () {
//              Navigator.pop(context);
//            },
//          ),
//          IconButton(
//            icon: Icon(
//              Icons.settings,
//              color: themeManager.getColor(TypeOfWidget.text),
//            ),
//            onPressed: () {
//              Navigator.pushNamed(context, '/settings');
//            },
//          ),
//          IconButton(
//            icon: Icon(
//              Icons.assessment,
//              color: themeManager.getColor(TypeOfWidget.text),
//            ),
//            onPressed: () {
//              _goToGPACalculator();
//            },
//          ),
//          skywardAPI.children != null
//              ? IconButton(
//                  icon: Icon(
//                    Icons.person,
//                    color: themeManager.getColor(TypeOfWidget.text),
//                  ),
//                  onPressed: () {
//                    _showChildrenChangeDialog();
//                  },
//                )
//              : Container(),
//          Theme(
//              data: Theme.of(context).copyWith(
//                cardColor: Colors.black,
//              ),
//              child: PopupMenuButton(
//                icon: Icon(
//                  Icons.more_vert,
//                  color: themeManager.getColor(TypeOfWidget.text),
//                ),
//                onSelected: (String selected) {
//                  switch (selected) {
//                    case 'settings':
//                      Navigator.pushNamed(context, '/settings');
//                      break;
//                    case 'gpaCalc':
//                      {
//                        _goToGPACalculator('TEST');
//                      }
//                      break;
//                    case 'devBash':
//                      showDialog(
//                          context: context,
//                          builder: (bC) {
//                            return HuntyDialogDebugCredentials(
//                                hint: 'Credentials',
//                                title: 'Debug Console',
//                                description: 'Developers Only',
//                                buttonText: 'Submit');
//                          });
//                  }
//                },
//                itemBuilder: (_) => <PopupMenuItem<String>>[
//                  PopupMenuItem<String>(
//                      child: const Text(
//                        'Settings',
//                        style: TextStyle(color: Colors.white),
//                      ),
//                      value: 'settings'),
//                  PopupMenuItem<String>(
//                      child: const Text(
//                        'GPA Calculator',
//                        style: TextStyle(color: Colors.white),
//                      ),
//                      value: 'gpaCalc'),
////                    PopupMenuItem<String>(
////                        child: const Text(
////                          'Developer Command',
////                          style: TextStyle(color: Colors.white),
////                        ),
////                        value: 'devBash'),
//                ],
//              ))
//        ],
      ),
      backgroundColor: themeManager.getColor(TypeOfWidget.background),
      body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
            Container(
              child: InkWell(
                child: Card(
                  color: themeManager.getColor(TypeOfWidget.text),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Container(
                    child: Text(
                      'Term: ${terms[currentTermIndex].termCode} / ${terms[currentTermIndex].termName}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    padding:
                        EdgeInsets.only(top: 20, bottom: 20, left: 0, right: 0),
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
              padding:
                  EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                children: body,
              ),
            )
          ])),
    );
  }
}
