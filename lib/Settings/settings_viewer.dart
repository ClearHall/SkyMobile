import 'package:flutter/material.dart';
import 'themeColorManager.dart';
import 'package:skymobile/HelperUtilities/globalVariables.dart';

class SettingsViewer extends StatefulWidget {
  SettingsViewer({Key key}) : super(key: key);

  @override
  _SettingsViewerState createState() => _SettingsViewerState();
}

class _SettingsViewerState extends State<SettingsViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        iconTheme: IconThemeData(
        color: themeManager.getColor(TypeOfWidget.text), size: 30),
    backgroundColor: themeManager.getColor(TypeOfWidget.background),
    title: Align(alignment: Alignment.centerLeft, child: Text('Settings',
    textAlign: TextAlign.center,
    style: TextStyle(
    color: themeManager.getColor(TypeOfWidget.text),
    fontSize: 30,
    fontWeight: FontWeight.w700)),
    ),),
    backgroundColor: Colors.black,
    body: Center());
  }
}
