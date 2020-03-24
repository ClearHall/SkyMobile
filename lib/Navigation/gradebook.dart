import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skymobile/SupportWidgets/biometric_blur_view.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skyscrapeapi/data_types.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/ExtraViewPackages/hunty_dialogs.dart';
import 'package:skymobile/HelperUtilities/gpa_calculator_support_utils.dart';
import 'package:skyscrapeapi/sky_core.dart';

class TermViewerPage extends StatefulWidget {
  List args;

  TermViewerPage(this.args);

  @override
  _TermViewer createState() => new _TermViewer(args[0], args[1], args[2]);
}

class _TermViewer extends BiometricBlur<TermViewerPage> {
  int currentTermIndex = 0;
  List<Message> messages;
  Gradebook gradebook;
  String currUser;
  bool developerModeEnabled = false;

  _TermViewer(this.gradebook, this.currUser, this.developerModeEnabled);

  @override
  void initState() {
    super.initState();
    _setIntTerm();
    _retrieveMessagesInTheBackground();
  }

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
    }, title: 'Loading', description: ('Getting your grades..'));

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
      Navigator.pushNamed(
          context, '/gpacalculatorschoolyear', arguments: [result, gradebook]);
    }
  }

  _goToAssignmentsViewer(Grade gradeBox, String courseName) async {
    bool isCancelled = false;
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled = true;
    }, title: 'Loading', description: ('Getting your grades..'));

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

  _setIntTerm() {
    Term currentTerm;
    for (Class klassenzimmer in gradebook.classes)
      for (int i = 0; i < klassenzimmer.grades.length; i++) {
        if (klassenzimmer.grades[i] is Grade) {
          currentTerm = (klassenzimmer.grades[i] as Grade).term;
        }
      }
    currentTermIndex = gradebook.terms.indexOf(currentTerm);
    if (currentTermIndex < 0) currentTermIndex = 0;
  }

  _submitAndChangeChild(int ind) async {
    account.switchUserIndex(ind);

    var dialog1 = HuntyDialogLoading('Cancel', () {},
        title: 'Loading', description: ('Getting your grades..'));

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
                    'An error occured and we could not get your grades. Please report this to a developer! An error occured while parsing your grades.',
                buttonText: 'Ok');
          });
    }
  }

  refresh() async{
    var dialog = HuntyDialogLoading('Cancel', () {
    }, title: 'Loading', description: ('Getting your grades..'),);
    dialog.restrictCancel = true;

    showDialog(barrierDismissible: false, context: context, builder: (BuildContext context) => dialog);

    await refreshGradebook();
    setState(() {
      Navigator.of(context).pop();
    });
  }

  bool expanded = false;

  @override
  Widget generateBody(BuildContext context) {
    List<String> childNames = account.getChildrenNames();
    if(!developerModeEnabled)
      currentChild = account
          .retrieveAccountIfParent()
          ?.dataID;
    final FixedExtentScrollController scrollController =
    FixedExtentScrollController(initialItem: currentTermIndex);

    List<Widget> cupPickerWid = [];
    for (Term term in gradebook.terms) {
      cupPickerWid.add(Container(
        child: Text('${term.termCode} / ${term.termName}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, color: Colors.white)),
        padding: EdgeInsets.only(top: 8),
      ));
    }

    List<Widget> body = [];

    for (Class klass in gradebook.classes) {
      GradebookNode gradeBox = klass.retrieveNodeByTerm(
          gradebook.terms[currentTermIndex]);

      String grade = gradeBox != null
          ? (gradeBox is Grade)
          ? gradeBox.grade
          : (gradeBox as Behavior).behavior
          : '';

      body.add(Card(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                            MediaQuery.of(context).size.width / 6 * 4),
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

    List<Widget> drawerWidgets = [
      DrawerHeader(
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            developerModeEnabled ? currentChild : currUser.replaceAll(
                " ", "\n"),
            style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text),
            ),
            maxLines: 10,
          ),
        ),
      ),
      ListTile(
        leading: Container(padding: EdgeInsets.only(left: 10), child: Icon(
          Icons.settings,
          color: themeManager.getColor(TypeOfWidget.text),
        ),),
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
        leading: Container(padding: EdgeInsets.only(left: 10), child: Icon(
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
      (developerModeEnabled ? false : childNames != null)
          ? ListTile(
        leading: Container(padding: EdgeInsets.only(left: 10), child: Icon(
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
        leading: Container(padding: EdgeInsets.only(left: 10), child: Icon(
            Icons.message,
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
                    title: 'Uh-Oh',
                    description:
                    ('Messages hasn\'t finished loading yet. Please wait'),
                    buttonText: 'Ok'));
          } else {
            Navigator.pushNamed(context, '/messages', arguments: messages);
          }
        },
      ),
      ListTile(
        leading: Container(padding: EdgeInsets.only(left: 10), child: Icon(
          Icons.access_time,
          color: themeManager.getColor(TypeOfWidget.text),
        )),
        title: Text(
          'SkyLine',
          style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text), fontSize: 25),
        ),
        onTap: () {
          showDialog(context: context, builder: (context) => HuntyDialog(title: "SkyLine Integration", description: "Unfortunately, SkyLine is still in it's beta phases, we cannot connect you to SkyLine yet." , buttonText: "Ok"));
        },
      ),
      ListTile(
        leading: Container(padding: EdgeInsets.only(left: 10), child: Icon(
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
        leading: Container(padding: EdgeInsets.only(left: 10), child: Icon(
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
                  Container(padding: EdgeInsets.only(left: 10), child: Icon(
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
            onPressed: (){
              refresh();
            },
          ),
          SizedBox(width: 10,)
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
                          'Term: ${gradebook.terms[currentTermIndex]
                              .termCode} / ${gradebook.terms[currentTermIndex]
                              .termName}',
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
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                    children: body,
                  ),
                )
              ])),
    );
  }
}
