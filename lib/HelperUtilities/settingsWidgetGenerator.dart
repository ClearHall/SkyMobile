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
    Map<String, TextEditingController> arr = Map();

    for (String x in attributes['option'].keys) {
      TextEditingController y = TextEditingController();
      arr[x] = y;
      widgets.add(Container(
          child: Row(children: <Widget>[
        SizedBox(
          width: 10,
        ),
        Text(
          x + ": ",
          style: TextStyle(
              color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
            controller: y,
            keyboardType: TextInputType.number,
            style: TextStyle(color: themeManager.getColor(TypeOfWidget.text)),
            decoration: InputDecoration(
                hintText: attributes['option'][x].toString(),
                hintStyle:
                    TextStyle(color: themeManager.getColor(TypeOfWidget.text)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: themeManager.getColor(TypeOfWidget.text))),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: themeManager.getColor(TypeOfWidget.text))),
                labelText: "Number of Points",
                labelStyle: TextStyle(
                    color: themeManager.getColor(TypeOfWidget.text),
                    fontSize: 20)),
          ),
        ),
        SizedBox(
          width: 10,
        ),
      ])));
    }

    widgets.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Container(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () {
                  attributes['option']['AP'] = 10;
                  attributes['option']['PreAP'] = 5;
                  attributes['option']['Regular'] = 0;

                  run();
                },
                child: Text('Reset to Default',
                    style: TextStyle(
                        color: themeManager.getColor(TypeOfWidget.text),
                        fontSize: 20)),
              ),
            )),
        Container(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: InkWell(
                onTap: () {
                  arr.forEach((k, controller) {
                    attributes['option'][k] = int.tryParse(controller.text) ?? 0;
                  });

                  run();
                },
                child: Text('Enter',
                    style: TextStyle(
                        color: themeManager.getColor(TypeOfWidget.text),
                        fontSize: 20)),
              ),
            ))
      ]),
    );

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Card(
              child: Column(
                children: widgets,
              ),
              color: themeManager.getColor(TypeOfWidget.subBackground),
            ),
          ),
          Container(
              child: Card(
                  color: themeManager.getColor(TypeOfWidget.subBackground),
                  child: Container(
                    child: Text(
                      attributes['description'] ?? '',
                      style: TextStyle(
                          color: themeManager.getColor(TypeOfWidget.text),
                          fontSize: 20),
                    ),
                    padding: EdgeInsets.all(10),
                  ))),
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
    );
  }
}
