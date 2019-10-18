import 'package:flutter/material.dart';

class SettingsWidgetGenerator {
  static Widget generateSingleSettingsWidget(String settings, Map attributes, {Function run}) {
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
                      style: TextStyle(color: Colors.orange, fontSize: 20),
                    ),
                    padding: EdgeInsets.all(10),
                  ),
                  trailing: Switch(
                      value: attributes['option'] ?? false,
                      onChanged: (changedTo) {
                        attributes['option'] = changedTo;
                        if(run != null){
                          run();
                        }
                      }),
                ),
                color: Colors.white12),
            //padding: EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 10),
          ),
          Container(
              child: Card(
                  color: Colors.white12,
                  child: Container(
                    child: Text(
                      attributes['description'] ?? '',
                      style: TextStyle(color: Colors.orange, fontSize: 20),
                    ),
                    padding: EdgeInsets.all(10),
                  )))
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
    );
  }
}
