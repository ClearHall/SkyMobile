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
            child: Column(children: <Widget>[
              RichText(
                  text: TextSpan(
                      text: 'Main Developer\n',
                      style: TextStyle(fontSize: 50,),
                      children: [TextSpan(text: "Hunter Han",
                        style: TextStyle(fontSize: 15),)])),
              RichText(
                  text: TextSpan(
                      text: 'Graphic Designer\n',
                      style: TextStyle(fontSize: 50,),
                      children: [TextSpan(text: "Albon Wu",
                        style: TextStyle(fontSize: 15),)]))
            ],)));
  }
}
