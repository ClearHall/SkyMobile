import 'package:flutter/material.dart';
import 'package:skymobile/Settings/themeColorManager.dart';
import 'globalVariables.dart';
import 'customDialogOptions.dart';
import 'package:local_auth/local_auth.dart';

class BiometricBlur<T extends StatefulWidget> extends State<T> with WidgetsBindingObserver{
  bool shouldBlur = false;
  bool wasInPausedState = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Navigator.of(context).popUntil((route){
        return route.settings.name != null;
    });
    if(settings['Re-Authenticate With Biometrics']['option'])
      if(state == AppLifecycleState.paused && ModalRoute.of(context).isCurrent) {
        shouldBlur = true;
        wasInPausedState = true;
      }else if(wasInPausedState && state == AppLifecycleState.resumed && ModalRoute.of(context).isCurrent) {
        setState(() {
          wasInPausedState = false;
        });
      }else if(!wasInPausedState && state == AppLifecycleState.resumed && ModalRoute.of(context).isCurrent){
        setState(() {
          shouldBlur = false;
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
              runIfUserConfirms: (){
                _authenticate();
              },
              runIfUserCancels: (){
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
      } else if(e.code != 'auth_in_progress') {
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

  Widget blackScaffold(){
    return Scaffold(backgroundColor: themeManager.getColor(TypeOfWidget.background),);
  }

  Widget generateBody(BuildContext context){
    return Scaffold();
  }

  @override
  Widget build(BuildContext context) {
    if(shouldBlur && ModalRoute.of(context).isCurrent){
      _authenticate();
      return blackScaffold();
    }
    return generateBody(context);
  }
}