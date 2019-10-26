import 'package:flutter/material.dart';
import 'package:skymobile/HelperUtilities/jsonSaver.dart';
import 'package:skymobile/Settings/settingsWidgetGenerator.dart';
import 'themeColorManager.dart';
import 'package:skymobile/HelperUtilities/globalVariables.dart';

class SettingsViewer extends StatefulWidget {
  SettingsViewer({Key key}) : super(key: key);

  @override
  _SettingsViewerState createState() => _SettingsViewerState();
}

class _SettingsViewerState extends State<SettingsViewer> {
  void _saveData() {
    setState(() {
      JSONSaver jsonSaver = JSONSaver(FilesAvailable.settings);
      jsonSaver.saveListData(settings);
      int i = settings['Theme']['option'].values.toList().indexOf(true);
      themeManager.currentTheme = ThemeManager.colorNameToThemes.keys.toList()[
          ThemeManager.colorNameToThemes.values
              .toList()
              .indexOf(settings['Theme']['option'].keys.toList()[i])];
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> settingsWidgets = [];
    for (String k in settings.keys) {
      if (settings[k]['option'] is Map)
        settingsWidgets.add(
            SettingsWidgetGenerator.generateListSelectableSettings(
                k, settings[k],
                maxAmountSelectable: 1, run: _saveData));
      else
        settingsWidgets.add(
          SettingsWidgetGenerator.generateSingleSettingsWidget(k, settings[k],
              run: _saveData),
        );
    }

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: themeManager.getColor(TypeOfWidget.text), size: 30),
          backgroundColor: themeManager.getColor(TypeOfWidget.background),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text('Settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: themeManager.getColor(TypeOfWidget.text),
                    fontSize: 30,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: ListView(
            children: settingsWidgets,
          ),
        ));
  }
}
