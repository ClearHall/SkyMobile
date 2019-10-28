import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';
import 'package:skymobile/HelperUtilities/customDialogOptions.dart';
import 'package:skymobile/Settings/themeColorManager.dart';
import 'package:skyscrapeapi/data_types.dart';
import 'package:skymobile/HelperUtilities/globalVariables.dart';

class AssignmentInfoViewer extends StatefulWidget {
  MaterialColor secondColor;
  String courseName;

  AssignmentInfoViewer({this.secondColor, this.courseName});
  @override
  _AssignmentInfoViewerState createState() =>
      new _AssignmentInfoViewerState(courseName);
}

class _AssignmentInfoViewerState extends State<AssignmentInfoViewer>
    with WidgetsBindingObserver {
  String courseName;

  _AssignmentInfoViewerState(this.courseName);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (settings['Re-Authenticate With Biometrics']['option']) if (state ==
            AppLifecycleState.resumed &&
        ModalRoute.of(context).isCurrent) {
      _authenticate();
    } else if (ModalRoute.of(context).isCurrent) {
      setState(() {
        shouldBlur = true;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _authenticate() async {
    LocalAuthentication localAuthentication = LocalAuthentication();
    try {
      if (await localAuthentication.authenticateWithBiometrics(
          localizedReason:
              'Welcome back! To view your grades again, please authenticate.')) {
        setState(() {
          shouldBlur = false;
        });
      } else {
        await showDialog(
            context: context,
            builder: (bc) => HuntyDialogForConfirmation(
                  title: 'Authentication Error',
                  description:
                      "You have either cancelled the operation or failed authentication, would you like to re-attempt authentication?",
                  btnTextForConfirmation: 'Ok',
                  btnTextForCancel: 'Cancel',
                  runIfUserConfirms: () {
                    _authenticate();
                  },
                  runIfUserCancels: () {
                    Navigator.popUntil(context, (route) {
                      return route.settings.name == '/';
                    });
                  },
                ));
      }
    } catch (e) {
      if (e.code == 'LockedOut') {
        showDialog(
            context: context,
            builder: (bc) => HuntyDialog(
                title: 'Authentication Error',
                description: e.message + "\nExit and re-enter the app.",
                buttonText: 'Ok'));
      } else if (e.code != 'auth_in_progress') {
        showDialog(
            context: context,
            builder: (bc) => HuntyDialog(
                title: 'Authentication Error',
                description: e.message +
                    '\nSkyMobile will disable authentication for you.',
                buttonText: 'Ok'));
        setState(() {
          settings['Biometric Authentication']['option'] = false;
          settings['Re-Authenticate With Biometrics']['option'] = false;
          shouldBlur = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (shouldBlur)
      return Scaffold(
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
      );
    List<Widget> body = [];
    for (AssignmentInfoBox box in assignmentInfoBoxes) {
      String uiMessage = box.getUIMessage();
      body.add(Card(
        color: themeManager.getColor(TypeOfWidget.subBackground),
        child: Container(
          alignment: Alignment.centerLeft,
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 6 * 4.4),
          padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
          child: Text(
            uiMessage,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
            textAlign: TextAlign.start,
          ),
        ),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: themeManager.getColor(TypeOfWidget.text), size: 30),
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(courseName != null ? courseName : 'Assignments',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: themeManager.getColor(TypeOfWidget.text),
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
        ),
      ),
      backgroundColor: themeManager.getColor(TypeOfWidget.background),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: body,
        ),
      ),
    );
  }
}
