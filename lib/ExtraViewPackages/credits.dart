import 'package:flutter/material.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skymobile/SupportWidgets/biometric_blur_view.dart';

class Credits extends StatefulWidget {
  Credits();
  @override
  _CreditsState createState() => new _CreditsState();
}

class _CreditsState extends BiometricBlur<Credits> {
  @override
  Widget generateBody(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: themeManager.getColor(TypeOfWidget.text), size: 30),
          backgroundColor: themeManager.getColor(TypeOfWidget.background),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text('Credits ',
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
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Main Developers',
                style:
                    TextStyle(fontSize: 30, color: themeManager.getColor(null), fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                '\nHunter Han',
                style:
                TextStyle(fontSize: 20, color: themeManager.getColor(null)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                '\nDamian Lall\n',
                style:
                TextStyle(fontSize: 20, color: themeManager.getColor(null)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Graphic Designer',
                style:
                TextStyle(fontSize: 30, color: themeManager.getColor(null), fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                '\nAlbon Wu\n',
                style:
                TextStyle(fontSize: 20, color: themeManager.getColor(null)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Beta Testers',
                style:
                TextStyle(fontSize: 30, color: themeManager.getColor(null), fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                '\nEvelyn N.\n',
                style:
                TextStyle(fontSize: 20, color: themeManager.getColor(null)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Damian L.\n',
                style:
                TextStyle(fontSize: 20, color: themeManager.getColor(null)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Kishlaya R.\n',
                style:
                TextStyle(fontSize: 20, color: themeManager.getColor(null)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Yifan M.\n',
                style:
                TextStyle(fontSize: 20, color: themeManager.getColor(null)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Play Store & App Store Graphics',
                style:
                TextStyle(fontSize: 30, color: themeManager.getColor(null), fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                '\nYifan M.\n',
                style:
                TextStyle(fontSize: 20, color: themeManager.getColor(null)),
              ),
            ),
          ],
        )));
  }
}