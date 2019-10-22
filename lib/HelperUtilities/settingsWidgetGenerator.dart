import 'package:flutter/material.dart';
import 'package:skymobile/HelperUtilities/globalVariables.dart';
import 'package:skymobile/HelperUtilities/themeColorManager.dart';

class SettingsWidgetGenerator {
  static Widget generateSingleSettingsWidget(String settings, Map attributes,
      {Function run}) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Card(
                child: ListTile(
                  title: Container(
                    child: Text(
                      settings + ":",
                      style: TextStyle(
                          color: themeManager.getColor(TypeOfWidget.text),
                          fontSize: 20),
                    ),
                    padding: EdgeInsets.all(10),
                  ),
                  trailing: Switch(
                    value: attributes['option'] ?? false,
                    onChanged: (changedTo) {
                      attributes['option'] = changedTo;
                      if (run != null) {
                        run();
                      }
                    },
                    activeColor: themeManager.getColor(TypeOfWidget.text),
                  ),
                ),
                color: themeManager.getColor(TypeOfWidget.subBackground)),
            //padding: EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 10),
          ),
          Container(
              child: Card(
                  color: Colors.white12,
                  child: Container(
                    child: Text(
                      attributes['description'] ?? '',
                      style: TextStyle(
                          color: themeManager.getColor(TypeOfWidget.text),
                          fontSize: 20),
                    ),
                    padding: EdgeInsets.all(10),
                  )))
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
    );
  }

  static Widget generateListSettingsWidget(String settings, Map attributes,
      {Function run}) {
    List<Widget> widgets = [];

    for (String x in attributes['option'].keys) {
      widgets.add(Container(
          child: ListTile(
        title: Text(x),
            //trailing: ,
      )));
    }

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Card(
                child: ListTile(
                  title: Container(
                    child: Text(
                      settings + ":",
                      style: TextStyle(
                          color: themeManager.getColor(TypeOfWidget.text),
                          fontSize: 20),
                    ),
                    padding: EdgeInsets.all(10),
                  ),
                  trailing: Switch(
                    value: attributes['option'] ?? false,
                    onChanged: (changedTo) {
                      attributes['option'] = changedTo;
                      if (run != null) {
                        run();
                      }
                    },
                    activeColor: themeManager.getColor(TypeOfWidget.text),
                  ),
                ),
                color: themeManager.getColor(TypeOfWidget.subBackground)),
            //padding: EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 10),
          ),
          Container(
              child: Card(
                  color: Colors.white12,
                  child: Container(
                    child: Text(
                      attributes['description'] ?? '',
                      style: TextStyle(
                          color: themeManager.getColor(TypeOfWidget.text),
                          fontSize: 20),
                    ),
                    padding: EdgeInsets.all(10),
                  )))
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
    );
  }
}
