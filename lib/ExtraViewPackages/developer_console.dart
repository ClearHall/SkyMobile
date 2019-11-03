import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/ExtraViewPackages/biometric_blur_view.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/HelperUtilities/manage_sky_vars.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skyscrapeapi/data_types.dart';

class DeveloperConsole extends StatefulWidget {
  DeveloperConsole({Key key}) : super(key: key);

  @override
  _DeveloperConsoleState createState() => _DeveloperConsoleState();
}

class _DeveloperConsoleState extends BiometricBlur<DeveloperConsole>{
  String currentText = 'Initialized SkyMobile Dev Console';

  Map variableModificationCommands = {
    'set': (List listObj, String index, String changeTo) {
      int i;
      if (index != 'all') {
        i = int.tryParse(index);
      }
      for (int j = 0; j < listObj.length; j++) {
        if (i != null) {
          if (j == i) {
            _setObjInList(listObj, i, changeTo);
          }
        } else {
          _setObjInList(listObj, j, changeTo);
        }
      }
      return 'Command completed successfully.';
    },
    'remove': (List listObj, String index, Object placeholder) {
      int i;
      if (index != 'all') {
        i = int.tryParse(index);
      }
      for (int j = listObj.length - 1; j >= 0; j--) {
        if (i != null) {
          if (j == i) listObj.removeAt(i);
        } else {
          listObj.removeAt(j);
        }
      }
      return 'Command completed successfully.';
    },
    'modvar': (var obj, String valMod, var changeTo){
      if(obj != 'envar') throw SkywardError('Non envar request.');
      if(SkyVars.modifyVar(valMod, changeTo)){
        return 'Successfully modified value';
      }else{
        return 'Failed to modify value';
      }
    }
  };

  static _setObjInList(List listObj, int ind, String changeTo) {
    Object thing = listObj[ind];
    switch (thing.runtimeType) {
      case LessInfoBox:
        (thing as LessInfoBox).behavior = changeTo;
        break;
      case GradeBox:
        (thing as GradeBox).grade = changeTo;
        break;
    }
  }

  _runCommand(String command) {
    List<String> split = command.toLowerCase().trim().split(' ');

    currentText += '\n>$command';
    currentText += '\n';
    // BEGIN THE TRANSLATION PROCESS!!!!!
    if (split.length > 0) {
      String command = split[0];
      var modifier;
      if(split.length > 1){
        if(split[1] == 'gradebook') modifier = gradeBoxes;
        else if(split[1] == 'terms') modifier = terms;
        else if(split[1] == 'envar'){
          SkyVars.getVars();
          modifier = 'envar';
        }
      }

      if (command == 'help') {
        currentText += 'Commands Available\nhelp: Displays this message.\nset and remove: Sets and Remove values from the gradebook. Syntax of this command is \'<set/remove> <gradebook/terms> <all/index> <(not needed if remove) value to change to>\'\ndisplay: Displays what is shown in the second parameter.';
      } else if (command == 'display') {
          if(split.length < 3)
            currentText += modifier.toString();
          else
            currentText += modifier[int.parse(split[2])].toString();
      }else if (variableModificationCommands.keys.contains(command)) {
        String change = split.length > 3 ? split[3] : null;
        currentText += variableModificationCommands[command](modifier, split[2], change);
      } else {
        currentText +=
            'Not a command.\nUse \'help\' to display available commands.';
      }
    }
  }

  ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  Widget generateBody(BuildContext context) {
    Timer(Duration(milliseconds: 500), (){
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    return Scaffold(
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: themeManager.getColor(TypeOfWidget.text), size: 30),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text('Developer Console',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: themeManager.getColor(TypeOfWidget.text),
                    fontSize: 30,
                    fontWeight: FontWeight.w700)),
          ),
          backgroundColor: themeManager.getColor(TypeOfWidget.background),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.refresh), onPressed: (){
              currentText = '';
              setState(() {
                currentText = 'Console refreshed.';
              });
            },)
          ],
        ),
        body: Center(
            child: Column(children: <Widget>[
              Expanded(child:
          Container(
              padding: EdgeInsets.only(top: 5, left: 15, right: 15),
              child: Align(
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(currentText,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: themeManager.getColor(null))),
                ),
              ))),
          Container(
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  color: themeManager.getColor(TypeOfWidget.background),
                    padding: EdgeInsets.only(
                        top: 20, left: 16, right: 16, bottom: 15),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      autofocus: false,
                      style: TextStyle(color: themeManager.getColor(null)),
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(18),
                          labelText: "Command",
                          labelStyle: TextStyle(
                              color: themeManager.getColor(TypeOfWidget.text)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      themeManager.getColor(TypeOfWidget.text),
                                  width: 2),
                              borderRadius: BorderRadius.circular(16)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      themeManager.getColor(TypeOfWidget.text),
                                  width: 2),
                              borderRadius: BorderRadius.circular(16))),
                      onFieldSubmitted: (v) {
                        setState(() {
                          try {
                            _runCommand(v);
                          }catch(e){
                            currentText += '\n' + e.toString();
                          }
                        });
                      },
                    )),
              ))
        ])));
  }
}
