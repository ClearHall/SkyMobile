import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:skymobile/ExtraViewPackages/hunty_dialogs.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/Settings/custom_theme_circle_icon.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';

class SettingsWidgetGenerator {
  static runChangeTo(bool changedTo, bool biometrics, Map attributes,
      Function run, Function(PlatformException) runIfBioFailed) async {
    if (biometrics) {
      LocalAuthentication localAuthentication = LocalAuthentication();
      try {
        if (await localAuthentication.authenticateWithBiometrics(
            localizedReason: 'Authentication to change biometrics option.',
            useErrorDialogs: false)) {
          attributes['option'] = changedTo;
          if (run != null) {
            run();
          }
        }
      } catch (e) {
        runIfBioFailed(e);
      }
    } else {
      attributes['option'] = changedTo;
      if (run != null) {
        run();
      }
    }
  }

  static Widget generateSingleSettingsWidget(String settings, Map attributes,
      {Function run,
      bool requiresBiometricsToDisable = false,
      Function(PlatformException) runIfBiometricsFailed}) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
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
                      runChangeTo(changedTo, requiresBiometricsToDisable,
                          attributes, run, runIfBiometricsFailed);
                    },
                    activeColor: themeManager.getColor(TypeOfWidget.text),
                  ),
                ),
                color: themeManager.getColor(TypeOfWidget.subBackground)),
            //padding: EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 10),
          ),
          (attributes['description'] as String).isNotEmpty
              ? Container(
                  child: Container(
                  child: Text(
                    attributes['description'] ?? '',
                    style: TextStyle(
                        color: themeManager.getColor(TypeOfWidget.text),
                        fontSize: 20),
                  ),
                  padding: EdgeInsets.all(10),
                ))
              : Container()
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
    );
  }

  static Widget generateListSettingsWidget(
      String settings, Map attributes, Map<String, TextEditingController> arr,
      {Function run}) {
    List<Widget> widgets = [];

    for (String x in attributes['option'].keys) {
      TextEditingController y = arr[x];
      if (y == null) {
        arr[x] = TextEditingController();
        y = arr[x];
      }
      widgets.add(Container(
          child: Row(children: <Widget>[
        SizedBox(
          width: 20,
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
                hintText: 'Number of points',
                hintStyle: TextStyle(
                    color: themeManager
                        .getColor(TypeOfWidget.text)
                        .withAlpha(150)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: themeManager.getColor(TypeOfWidget.text))),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: themeManager.getColor(TypeOfWidget.text))),
                labelText: "${attributes['option'][x]}",
                labelStyle: TextStyle(
                    color: themeManager
                        .getColor(TypeOfWidget.text)
                        .withOpacity(.5),
                    fontSize: 20)),
            onSubmitted: (sub) {
              y.text = sub;
            },
          ),
        ),
        SizedBox(
          width: 20,
        ),
      ])));
    }

    widgets.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: 20, right: 20),
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
                    if (controller.text.isNotEmpty)
                      attributes['option'][k] =
                          int.tryParse(controller.text) ?? 0;
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: widgets,
              ),
              color: themeManager.getColor(TypeOfWidget.subBackground),
            ),
          ),
          (attributes['description'] as String).isNotEmpty
              ? Container(
                  child: Container(
                  child: Text(
                    attributes['description'] ?? '',
                    style: TextStyle(
                        color: themeManager.getColor(TypeOfWidget.text),
                        fontSize: 20),
                  ),
                  padding: EdgeInsets.all(10),
                ))
              : Container()
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
    );
  }

  static Widget generateColorSelectableSetting(
      String setting, Map attributes, BuildContext context, Function color) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: ListTile(
                    title: Container(
                      child: Text(
                        setting + ":",
                        style: TextStyle(
                            color: themeManager.getColor(TypeOfWidget.text),
                            fontSize: 20),
                      ),
                      padding: EdgeInsets.all(10),
                    ),
                    trailing: FlatButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => HuntyDialogForConfirmation(
                                  title: 'Custom Theme Setup',
                                  description:
                                      'Welcome to custom theme setup. Here you will setup your own theme!',
                                  runIfUserConfirms: () async {
                                    loopDiags(0, attributes, context, color);
                                  },
                                  btnTextForConfirmation: 'Let\'s Start',
                                  btnTextForCancel: 'Cancel'));
                        },
                        child: // (attributes['option'] as ColorTheme).unset() ?
                            attributes['option'].unset() ? Text('None Set',
                                style: TextStyle(
                                    color: themeManager
                                        .getColor(TypeOfWidget.text),
                                    fontSize: 20)) : CustomPaint(painter: ThemeIcon(), ) // : Container()
                        )),
                color: themeManager.getColor(TypeOfWidget.subBackground)),
            //padding: EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 10),
          ),
          Container(
              child: Container(
            child: Text(
              attributes['description'] ?? '',
              style: TextStyle(
                  color: themeManager.getColor(TypeOfWidget.text),
                  fontSize: 20),
            ),
            padding: EdgeInsets.all(10),
          ))
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
    );
  }

  static loopDiags(
      int i, Map attributes, BuildContext context, Function color) {
    if (i > 1){
      return;
    }
    Color couler =
        i == 0 ? attributes['option'].primary : attributes['option'].secondary;
    showDialog(
        context: context,
        builder: (bcontext) {
          context = bcontext;
          return HuntyDialog(
              title: 'Choose a Color',
              description: 'Here you will choose your ' +
                  (i == 0 ? 'primary' : 'secondary') +
                  ' color. This is used in things such as ' +
                  (i == 0 ? 'text' : 'buttons') +
                  '.',
              buttonText: 'Ok');
        }).then((ba) => showDialog(
        context: context,
        builder: (bcontext) {
          context = bcontext;
          return AlertDialog(
            backgroundColor: themeManager.getColor(TypeOfWidget.background),
            titlePadding: const EdgeInsets.all(0.0),
            contentPadding: const EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            content: SingleChildScrollView(
              child: Theme(
                data: settings['Dark Mode']['option']
                    ? ThemeData.dark()
                    : ThemeData.light(),
                child: SlidePicker(
                  paletteType: PaletteType.rgb,
                  enableAlpha: false,
                  displayThumbColor: true,
                  showLabel: false,
                  showIndicator: true,
                  indicatorBorderRadius: const BorderRadius.vertical(
                    top: const Radius.circular(25.0),
                  ),
                  pickerColor: couler == null
                      ? (i == 0
                          ? themeManager.currentTheme.primary
                          : themeManager.currentTheme.secondary)
                      : (couler),
                  onColorChanged: (Color c) {
                    color(c, i == 0);
                  },
                ),
              ),
            ),
          );
        }).then((value) => loopDiags(i + 1, attributes, context, color)));
  }

  static Widget generateListSelectableSettings(String settings, Map attributes,
      {Function run, int maxAmountSelectable}) {
    List<Widget> widgets = [];
    Map options = attributes['option'];

    for (String x in options.keys) {
      widgets.add(Container(
          child: ListTile(
              title: Text(
                x + ": ",
                style: TextStyle(
                    color: themeManager.getColor(TypeOfWidget.text),
                    fontSize: 20),
              ),
              trailing: Switch(
                value: options[x],
                activeColor: themeManager.getColor(TypeOfWidget.text),
                onChanged: (newVal) {
                  options[x] = newVal;
                  for (int i = 0; i < options.keys.length; i++) {
                    if (options.keys.toList()[i] != x &&
                        maxAmountSelectable != null &&
                        options[options.keys.toList()[i]]) {
                      maxAmountSelectable--;
                      if (maxAmountSelectable <= 0)
                        options[options.keys.toList()[i]] = false;
                    }
                  }
                  run();
                },
              ))));
    }

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                child: Column(
                  children: widgets,
                ),
              ),
              color: themeManager.getColor(TypeOfWidget.subBackground),
            ),
          ),
          (attributes['description'] as String).isNotEmpty
              ? Container(
                  child: Container(
                  child: Text(
                    attributes['description'] ?? '',
                    style: TextStyle(
                        color: themeManager.getColor(TypeOfWidget.text),
                        fontSize: 20),
                  ),
                  padding: EdgeInsets.all(10),
                ))
              : Container()
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
    );
  }
}
