import 'package:flutter/material.dart';
import 'package:skymobile/HelperUtilities/globalVariables.dart';
import 'package:skymobile/HelperUtilities/settingsWidgetGenerator.dart';
import 'package:skymobile/HelperUtilities/themeColorManager.dart';
import 'supportUtils.dart';

class GPACalculatorSettings extends StatefulWidget {
  GPACalculatorSettings({Key key}) : super(key: key);

  @override
  _GPACalculatorSettingsState createState() => _GPACalculatorSettingsState();
}

class _GPACalculatorSettingsState extends State<GPACalculatorSettings> {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      Container(child: Card(
        color: Colors.white12,
        child: Container(
          child: Text(
            'Tick or change the settings depending on your district or college. Read descriptions carefully verify that the settings are correct.',
            style: TextStyle(color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
          ),
          padding: EdgeInsets.all(10),
        ),
      ), padding: EdgeInsets.only(left: 10, right: 10, top: 10),)
    ];
    for (String k in extraGPASettings.keys) {
      if(extraGPASettings[k]['option'] is Map){
        widgets.add(SettingsWidgetGenerator.generateListSettingsWidget(k, extraGPASettings[k], run: () {
          saveExtraGPASettings();
        }));
      }else {
        widgets.add(SettingsWidgetGenerator.generateSingleSettingsWidget(
            k, extraGPASettings[k], run: () {
          saveExtraGPASettings();
        }));
      }
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: Text('4.0 Scale Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: ListView(children: widgets),
        ));
  }
  //Widget _generateSettingsClickable(String setting, )
}
