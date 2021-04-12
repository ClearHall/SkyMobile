import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skymobile/Settings/settings_viewer.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import '../HelperUtilities/global.dart';
import '../ExtraViewPackages/hunty_dialogs.dart';
import 'package:local_auth/local_auth.dart';

bool shouldBlur = false;

class BiometricBlur<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  bool wasInPausedState = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (wasInPausedState) {
      Navigator.of(context).popUntil((route) {
        return route.settings.name != null;
      });
    }
    if (settings['Re-authenticate with Biometrics']
        ['option']) if (state == AppLifecycleState.paused) {
      setState(() {
        shouldBlur = true;
        wasInPausedState = true;
      });
    } else if (ModalRoute.of(context).isCurrent &&
        shouldBlur &&
        state == AppLifecycleState.resumed) {
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          shouldBlur = true;
        });
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
              'Welcome back! To view your grades again, please authenticate.',
          useErrorDialogs: false)) {
        setState(() {
          shouldBlur = false;
        });
      } else {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (bc) => HuntyDialog(
                title: 'Authentication Error',
                description: 'Authentication failed.',
                buttonText: 'Ok'));
      }
//      } else {
//        await _ohNoDialog();
//      }
    } catch (e) {
      if (e.code == 'LockedOut') {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (bc) => HuntyDialog(
                title: 'Authentication Error',
                description: e.message,
                buttonText: 'Ok'));
      } else {
        //} else if (e.code != 'auth_in_progress') {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (bc) => HuntyDialog(
                title: 'Authentication Error',
                description: e.message +
                    '\nSkyMobile will disable authentication for you.',
                buttonText: 'Ok'));
        setState(() {
          settings['Biometric Authentication']['option'] = false;
          settings['Re-authenticate with Biometrics']['option'] = false;
          shouldBlur = false;
          saveSettingsData();
        });
      }
//      } else {
//        await showDialog(
//            context: context,
//            builder: (bc) => HuntyDialog(
//                title: 'Authentication Error',
//                description: e.message +
//                    '\nSkyMobile will disable authentication for you.',
//                buttonText: 'Ok'));
//        settings['Biometric Authentication']['option'] = false;
//        settings['Re-authenticate with Biometrics']['option'] = false;
//        saveSettingsData();
//      }
    }
  }

  Widget blackScaffold() {
    wasInPausedState = false;
    return WillPopScope(
        child: Scaffold(
          backgroundColor: themeManager.getColor(TypeOfWidget.background),
          body: Center(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Re-Authenticate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: themeManager.getColor(TypeOfWidget.text),
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2)),
                  Container(
                    padding: EdgeInsets.only(left: 30, right: 30, top: 10),
                    child: Text(
                        'You have left the app, please re-authenticate to view your grades again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: themeManager.getColor(null),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2)),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Card(
                        color: themeManager.getColor(TypeOfWidget.button),
                        child: InkWell(
                            onTap: () {
                              Navigator.popUntil(context, (route) {
                                return route.settings.name == '/';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text('Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: themeManager.getColor(null),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2)),
                            )),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Card(
                        color: themeManager.getColor(TypeOfWidget.button),
                        child: InkWell(
                            onTap: () {
                              _authenticate();
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text('Authenticate',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: themeManager.getColor(null),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2)),
                            )),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        onWillPop: () => Future(() {
              _authenticate();
              return false;
            }));
  }

  Widget generateBody(BuildContext context) {
    return Scaffold();
  }

  @override
  Widget build(BuildContext context) {
    if (shouldBlur && ModalRoute.of(context).isCurrent) {
      return blackScaffold();
    }
    return generateBody(context);
  }
}
