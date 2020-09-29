import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:skymobile/ExtraViewPackages/hunty_dialogs.dart';
import 'package:skymobile/ExtraViewPackages/selector.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/HelperUtilities/gpa_calculator_support_utils.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skymobile/SupportWidgets/biometric_blur_view.dart';
import 'package:skyscrapeapi/sky_core.dart';

class TermViewerPage extends StatefulWidget {
  final List args;

  TermViewerPage(this.args);

  @override
  _TermViewer createState() => new _TermViewer(args[0], args[1], args[2]);
}

class _TermViewer extends BiometricBlur<TermViewerPage> {
  int currentTermIndex = 0;
  int indexOfGradebookSelected = 0;
  List<Message> messages;
  Gradebook gradebook;
  String currUser;
  bool developerModeEnabled = false;

  final tween = MultiTrackTween([
    Track("color1")
        .add(Duration(seconds: 2),
        ColorTween(begin: Colors.red, end: Colors.yellow))
        .add(Duration(seconds: 2),
        ColorTween(begin: Colors.yellow, end: Colors.blue))
        .add(Duration(seconds: 2),
        ColorTween(begin: Colors.blue, end: Colors.purple)),
    Track("color2")
        .add(Duration(seconds: 2),
        ColorTween(begin: Colors.orange, end: Colors.green))
        .add(Duration(seconds: 2),
        ColorTween(begin: Colors.green, end: Colors.indigo))
        .add(Duration(seconds: 2),
        ColorTween(begin: Colors.indigo, end: Colors.deepPurple))
  ]);

  _TermViewer(this.gradebook, this.currUser, this.developerModeEnabled);

  @override
  void initState() {
    super.initState();
    _setIntTerm();
    _retrieveMessagesInTheBackground();
  }

  // Please do not await for me!
  _retrieveMessagesInTheBackground() async {
    messages = await account.getMessages();
  }

  refreshGradebook() async {
    gradebook = await account.getGradebook(forceRefresh: true);
  }

  _goToGPACalculator() async {
    bool isCancelled = false;
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled = true;
    }, title: 'Loading', description: ('Please wait...'));

    showDialog(context: context, builder: (BuildContext context) => dialog)
        .then((val) {
      isCancelled = true;
    });

    var result;

    try {
      result = await account.getHistory();
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

    if (!isCancelled && result != null) {
      result = await gpaCalculatorSettingsReadForCurrentSession(result);
      await getTermsToRead();
      Navigator.of(context, rootNavigator: true).popUntil((result) {
        return result.settings.name == '/termviewer';
      });
      Navigator.pushNamed(context, '/gpacalculatorschoolyear',
          arguments: [result, gradebook]);
    }
  }

  _goToAssignmentsViewer(Grade gradeBox, String courseName) async {
    bool isCancelled = false;
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled = true;
    }, title: 'Loading', description: ('Please wait...'));

    showDialog(context: context, builder: (BuildContext context) => dialog)
        .then((val) {
      isCancelled = true;
    });

    var result;

    try {
      result = await account.getAssignmentsFrom(gradeBox);
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

    if (!isCancelled && result != null) {
      Navigator.of(context, rootNavigator: true).popUntil((result) {
        return result.settings.name == '/termviewer';
      });
      Navigator.pushNamed(context, '/assignmentsviewer',
          arguments: [courseName, result, gradebook]);
    }
  }

  _goToStudentInfo() async {
    bool isCancelled = false;
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled = true;
    }, title: 'Loading', description: ('Please wait...'));

    showDialog(context: context, builder: (BuildContext context) => dialog)
        .then((val) {
      isCancelled = true;
    });

    var result;

    try {
      result = await account.getStudentProfile();
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

    if (!isCancelled && result != null) {
      Navigator.of(context, rootNavigator: true).popUntil((result) {
        return result.settings.name == '/termviewer';
      });
      Navigator.pushNamed(context, '/studentinfo', arguments: [result]);
    }
  }

  _setIntTerm() {
    Term currentTerm;
    for (Class klassenzimmer
    in gradebook.gradebookSectors[indexOfGradebookSelected].classes)
      for (int i = 0; i < klassenzimmer.grades.length; i++) {
        if (klassenzimmer.grades[i] is Grade) {
          currentTerm = (klassenzimmer.grades[i] as Grade).term;
        }
      }
    currentTermIndex = gradebook
        .gradebookSectors[indexOfGradebookSelected].terms
        .indexOf(currentTerm);
    if (currentTermIndex < 0) currentTermIndex = 0;
  }

  _submitAndChangeChild(int ind) async {
    account.switchUserIndex(ind);

    var dialog1 = HuntyDialogLoading('Cancel', () {},
        title: 'Loading', description: ('Please wait...'));

    dialog1.restrictCancel = true;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => dialog1);

    try {
      Gradebook neu = await account.getGradebook(forceRefresh: true);

      setState(() {
        gradebook = neu;

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
                    'An error occurred while parsing your grades. Please report this to the developers!',
                buttonText: 'Ok');
          });
    }
  }

  refresh() async {
    var dialog = HuntyDialogLoading(
      'Cancel',
          () {},
      title: 'Loading',
      description: ('Please wait...'),
    );
    dialog.restrictCancel = true;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => dialog);

    await refreshGradebook();
    setState(() {
      Navigator.of(context).pop();
    });
  }

  bool expanded = false;

  @override
  Widget generateBody(BuildContext context) {
    List<String> childNames = account.getChildrenNames();
    if (!developerModeEnabled)
      currentChild = account
          .retrieveAccountIfParent()
          ?.dataID;

    List<Widget> body = [];

    if (gradebook.gradebookSectors[indexOfGradebookSelected].terms.length <=
        currentTermIndex) currentTermIndex = 0;

    List<String> cupPickerWid = [];
    for (Term term
    in gradebook.gradebookSectors[indexOfGradebookSelected].terms) {
      cupPickerWid.add('${term.termCode} / ${term.termName}');
    }

    for (Class klass
    in gradebook.gradebookSectors[indexOfGradebookSelected].classes) {
      GradebookNode gradeBox = klass.retrieveNodeByTerm(gradebook
          .gradebookSectors[indexOfGradebookSelected].terms[currentTermIndex]);

      String grade = gradeBox != null ? gradeBox.grade : '';

      body.add(Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (gradeBox != null && gradeBox is Grade)
                _goToAssignmentsViewer(gradeBox, klass.courseName);
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
                            MediaQuery
                                .of(context)
                                .size
                                .width / 6 * 4),
                        padding: EdgeInsets.only(
                            top: 15, left: 20, right: 20, bottom: 0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          klass.courseName,
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
                            top: 5, left: 20, right: 20, bottom: 0),
                        alignment: Alignment.centerLeft,
                        child: Text(klass.teacherName,
                            style: TextStyle(
                                color: themeManager.getColor(null),
                                fontSize: 15),
                            textAlign: TextAlign.start),
                      ),
                      Container(
                          padding: EdgeInsets.only(
                              top: 5, left: 20, right: 20, bottom: 15),
                          alignment: Alignment.centerLeft,
                          child: Text(klass.timePeriod,
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
                    child: grade == '100'
                        ? ControlledAnimation(
                      playback: Playback.MIRROR,
                      tween: tween,
                      duration: tween.duration,
                      builder: (context, anim) {
                        final LinearGradient linearGradient =
                        LinearGradient(
                            colors: [anim['color1'], anim['color2']]);
                        return ShaderMask(
                            shaderCallback: (bounds) =>
                                linearGradient.createShader(Rect.fromLTWH(
                                    0, 0, bounds.width, bounds.height)),
                            child: Text(
                              grade,
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ));
                      },
                    )
                        : Text(
                      grade,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: getColorFrom(grade),
                      ),
                    ))
              ],
            )),
        color: themeManager.getColor(TypeOfWidget.subBackground),
      ));
    }

    List<Widget> drawerWidgets = [
      DrawerHeader(
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            developerModeEnabled
                ? currentChild
                : currUser.replaceAll(" ", "\n"),
            style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text),
            ),
            maxLines: 10,
          ),
        ),
      ),
      ListTile(
        leading: Container(
          padding: EdgeInsets.only(left: 10),
          child: Icon(
            Icons.settings,
            color: themeManager.getColor(TypeOfWidget.text),
          ),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text), fontSize: 25),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/settings')
              .then((value) => setState(() {}));
        },
      ),
      ListTile(
        leading: Container(
            padding: EdgeInsets.only(left: 10),
            child: Icon(
              Icons.assessment,
              color: themeManager.getColor(TypeOfWidget.text),
            )),
        title: Text(
          'GPA Calculator',
          style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text), fontSize: 25),
        ),
        onTap: () {
          _goToGPACalculator();
        },
      ),
      ListTile(
        leading: Container(
            padding: EdgeInsets.only(left: 10),
            child: Icon(
              Icons.person,
              color: themeManager.getColor(TypeOfWidget.text),
            )),
        title: Text(
          'My Info',
          style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text), fontSize: 25),
        ),
        onTap: () {
          _goToStudentInfo();
        },
      ),
      (developerModeEnabled ? false : childNames != null)
          ? ListTile(
        leading: Container(
            padding: EdgeInsets.only(left: 10),
            child: Icon(
              expanded ? Icons.arrow_drop_down : Icons.arrow_drop_up,
              color: themeManager.getColor(TypeOfWidget.text),
            )),
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
      ListTile(
        leading: Container(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.message,
                color: themeManager.getColor(TypeOfWidget.text))),
        title: Text(
          'Messages',
          style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text), fontSize: 25),
        ),
        onTap: () {
          if (messages == null) {
            showDialog(
                context: context,
                builder: (b) => HuntyDialog(
                    title: 'Loading Messages',
                    description:
                    ('Message loading in progress, please wait.'),
                    buttonText: 'Ok'));
          } else {
            Navigator.pushNamed(context, '/messages', arguments: messages);
          }
        },
      ),
//      ListTile(
//        leading: Container(padding: EdgeInsets.only(left: 10), child: Icon(
//          Icons.access_time,
//          color: themeManager.getColor(TypeOfWidget.text),
//        )),
//        title: Text(
//          'SkyLine',
//          style: TextStyle(
//              color: themeManager.getColor(TypeOfWidget.text), fontSize: 25),
//        ),
//        onTap: () {
//          showDialog(context: context, builder: (context) => HuntyDialog(title: "SkyLine Integration", description: "Unfortunately, SkyLine is still in it's beta phases, we cannot connect you to SkyLine yet." , buttonText: "Ok"));
//        },
//      ),
      ListTile(
        leading: Container(
            padding: EdgeInsets.only(left: 10),
            child: Icon(
              Icons.info,
              color: themeManager.getColor(TypeOfWidget.text),
            )),
        title: Text(
          'Credits',
          style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text), fontSize: 25),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/credits');
        },
      ),
      ListTile(
        leading: Container(
            padding: EdgeInsets.only(left: 10),
            child: Icon(
              Icons.arrow_back,
              color: themeManager.getColor(TypeOfWidget.text),
            )),
        title: Text(
          'Logout',
          style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text), fontSize: 25),
        ),
        onTap: () {
          messages = null;
          developerModeEnabled = false;
          Navigator.popUntil(context, (pred) {
            return pred.settings.name == '/';
          });
        },
      ),
    ];

    for (int i = 0; i < drawerWidgets.length; i++) {
      if (drawerWidgets[i] is ListTile &&
          expanded &&
          ((drawerWidgets[i] as ListTile).title as Text).data ==
              'Change Child') {
        for (int j = 0; j < childNames.length; j++) {
          drawerWidgets.insert(
              i + 1,
              ListTile(
                leading: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(
                        Icons.person,
                        color: themeManager.getColor(TypeOfWidget.text),
                      )),
                ]),
                title: Text(
                  childNames[j],
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

    List<String> gradebookString = [];
    for (GradebookSector sec in gradebook.gradebookSectors)
      gradebookString.add(sec.name);

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
            child: Text(neiceban ? '内测版' : 'Gradebook',
                style: TextStyle(
                  color: themeManager.getColor(TypeOfWidget.text),
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ))),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              refresh();
            },
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      backgroundColor: themeManager.getColor(TypeOfWidget.background),
      body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                gradebook.gradebookSectors.length > 1 ? Container(
                  child: Selector(gradebookString, 'Gradebook', (int changed) {
                    setState(() {
                      indexOfGradebookSelected = changed;
                    });
                  }, indexOfGradebookSelected),
                  padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                ) : Container(),
                Container(
                  child: Selector(cupPickerWid, 'Term', (int changed) {
                    setState(() {
                      currentTermIndex = changed;
                    });
                  }, currentTermIndex),
                  padding:
                  EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                    children: body,
                  ),
                )
              ])),
    );
  }
}
