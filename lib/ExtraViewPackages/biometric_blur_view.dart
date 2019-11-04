import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skymobile/Settings/settings_viewer.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import '../HelperUtilities/global.dart';
import 'hunty_dialogs.dart';
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
    if (settings['Re-Authenticate With Biometrics']
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
//    } else if (!wasInPausedState &&
//        state == AppLifecycleState.resumed &&
//        ModalRoute.of(context).isCurrent) {
//      setState(() {
//        shouldBlur = false;
//      });
//    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _ohNoDialog() async {
    Navigator.of(context).popUntil((route) {
      return route.settings.name != null;
    });
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (bc) => HuntyDialogForConfirmation(
              title: 'Re-Authenticate',
              description: "Please re-authenticate?",
              btnTextForConfirmation: 'Ok',
              btnTextForCancel: 'Cancel',
              runIfUserConfirms: () {
                _authenticate();
              },
              runIfUserCancels: () {
                shouldBlur = false;
                Navigator.popUntil(context, (route) {
                  return route.settings.name == '/';
                });
              },
            ));
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
        await _ohNoDialog();
      }
    } catch (e) {
      if (e.code == 'LockedOut') {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (bc) => HuntyDialog(
                title: 'Authentication Error',
                description: e.message + "\nExit and re-enter the app.",
                buttonText: 'Ok'));
      } else if (e.code != 'auth_in_progress') {
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
          settings['Re-Authenticate With Biometrics']['option'] = false;
          shouldBlur = false;
        });
      } else {
        await showDialog(
            context: context,
            builder: (bc) => HuntyDialog(
                title: 'Authentication Error',
                description: e.message +
                    '\nSkyMobile will disable authentication for you.',
                buttonText: 'Ok'));
        settings['Biometric Authentication']['option'] = false;
        settings['Re-Authenticate With Biometrics']['option'] = false;
        saveSettingsData();
      }
    }
  }

  Widget blackScaffold() {
    wasInPausedState = false;
    return WillPopScope(
        child: Scaffold(
          backgroundColor: themeManager.getColor(TypeOfWidget.background),
          body: Center(
            child: Align(alignment: Alignment.center,
            child: Column(children: <Widget>[
              
            ],),),
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
