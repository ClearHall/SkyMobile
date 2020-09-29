import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skymobile/ExtraViewPackages/hunty_dialogs.dart';
import 'package:skymobile/HelperUtilities/DataPersist/json_saver.dart';
import 'package:skymobile/HelperUtilities/DataPersist/manage_sky_vars.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/Settings/settings_widget_generator.dart';
import 'package:skymobile/SupportWidgets/biometric_blur_view.dart';
import 'package:skymobile/SupportWidgets/constant_visibile_scrollbar.dart';
import 'package:skymobile/SupportWidgets/custom_overscroll_behavior.dart';
import 'package:skymobile/main.dart';

import 'theme_color_manager.dart';

void saveSettingsData() {
  if (!settings['Biometric Authentication']['option'])
    settings['Re-Authenticate With Biometrics']['option'] = false;
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.settings);
  jsonSaver.saveListData(settings);
  int i = settings['Theme']['option'].values.toList().indexOf(true);
  if(i > -1) {
    themeManager.currentTheme = ThemeManager.colorNameToThemes.keys.toList()[
    ThemeManager.colorNameToThemes.values
        .toList()
        .indexOf(settings['Theme']['option'].keys.toList()[i])];
    settings['Custom Theme']['option'] = ColorTheme.unset();
  }
}

class SettingsViewer extends StatefulWidget {
  SettingsViewer({Key key}) : super(key: key);

  @override
  _SettingsViewerState createState() => _SettingsViewerState();
}

class _SettingsViewerState extends BiometricBlur<SettingsViewer> {
  static const platform =
      const MethodChannel('com.lingfeishengtian.SkyMobile/choose_icon');
  List icons = ['icon1', 'icon2', 'icon3', 'icon4', 'iconchristmas'];

  changeIcon(String iconName) async {
    HuntyDialogLoading loading = HuntyDialogLoading(
      'Cancel',
      null,
      title: 'Loading',
      description: 'Loading new icon. The app may exit.',
    );
    loading.restrictCancel = true;
    showDialog(
        context: context, builder: (_) => loading, barrierDismissible: false);
    try {
      await platform.invokeMethod('changeIcon', {'iconName': iconName});
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (_) => HuntyDialog(
              title: 'Icon Change',
              description: 'Operation succeeded.' +
                  (Platform.isAndroid ? ' The app will now restart.' : ''),
              buttonText: 'Ok'));
    } on PlatformException catch (e) {
      print(e);
    }
  }

  void colorChange(Color c, bool prim){
    if(c != null) {
      Color mat = Color(c.hashCode);

      if(prim)
        themeManager.currentTheme.primary = mat;
      else
        themeManager.currentTheme.secondary = mat;

      setState(() {
        settings['Theme']['option'] =
          Map.fromIterables(
              ThemeManager.colorNameToThemes.values,
              List.generate(ThemeManager.colorNameToThemes.length, (i) {
                return false;
              }));
      settings['Custom Theme']['option'] =
          themeManager.currentTheme;
      saveSettingsData();
      });
    }
  }

  @override
  Widget generateBody(BuildContext context) {
    List<Widget> settingsWidgets = [];
    for (String k in settings.keys) {
      if (settings[k]['option'] is Map)
        settingsWidgets.add(
            SettingsWidgetGenerator.generateListSelectableSettings(
                k, settings[k],
                maxAmountSelectable: 1, run: () {
          setState(() {
            saveSettingsData();
          });
        }));
      else if(settings[k]['option'] is ColorTheme)
        settingsWidgets.add(SettingsWidgetGenerator.generateColorSelectableSetting(k, settings[k], context, colorChange));
      else
        settingsWidgets.add(
          SettingsWidgetGenerator.generateSingleSettingsWidget(k, settings[k],
              run: () {
                setState(() {
                  saveSettingsData();
                });
              },
              requiresBiometricsToDisable: k == 'Biometric Authentication',
              runIfBiometricsFailed: (e) {
                if (e is PlatformException) {
                  if (e.code == 'LockedOut') {
                    showDialog(
                        context: context,
                        builder: (bc) => HuntyDialog(
                            title: 'Authentication Error',
                            description: e.message,
                            buttonText: 'Ok'));
                  } else {
                    showDialog(
                        context: context,
                        builder: (bc) => HuntyDialog(
                            title: 'Authentication Error',
                            description: e.message +
                                '\nSkyMobile will disable authentication.',
                            buttonText: 'Ok'));
                    setState(() {
                      settings['Biometric Authentication']['option'] = false;
                    });
                  }
                }
              },
              force: (k == 'Re-Authenticate With Biometrics' &&
                  !settings['Biometric Authentication']['option'])
                  ? false
                  : null),
        );
    }

    List<Widget> widgets = [];
    for (String iconName in icons) {
      widgets.add(RaisedButton(
        padding: EdgeInsets.all(0),
        onPressed: () {
          changeIcon("I" + iconName.substring(1));
        },
        child: Card(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Image(
                height: 100,
                width: 100,
                image:
                    AssetImage('assets/CustomizableIcons/$iconName' + '.png'),
              ),
            )),
        color: Colors.transparent,
      ));
    }

    if (SkyVars.skyVars['iconchangesupport'] == 'true') {
      settingsWidgets.add(Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: <Widget>[
            Container(
                child: Container(
              child: Text(
                'Change icon!',
                style: TextStyle(
                    color: themeManager.getColor(TypeOfWidget.text),
                    fontSize: 20),
              ),
              padding: EdgeInsets.all(10),
            )),
            SingleChildScrollViewWithScrollbar(
                scrollDirection: Axis.horizontal,
                scrollbarColor: Colors.white30.withOpacity(0.75),
                scrollbarThickness: 8.0,
                child: SingleChildScrollView(
                  child: Row(
                    children: widgets,
                  ),
                  scrollDirection: Axis.horizontal,
                ))
          ],
        ),
      ));
      settingsWidgets.add(SizedBox(
        height: 15,
      ));
    }

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: themeManager.getColor(TypeOfWidget.text), size: 30),
          backgroundColor: themeManager.getColor(TypeOfWidget.background),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(neiceban ? '内测版' : 'Settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: themeManager.getColor(TypeOfWidget.text),
                    fontSize: 30,
                    fontWeight: FontWeight.w700)),
          ),
          actions: <Widget>[
            MyHomePageState.timesPressedSwitch >= 15 ||
                    SkyVars.getVar('permdev') == true
                ? IconButton(
                    icon: Icon(
                      Icons.tv,
                      color: themeManager.getColor(TypeOfWidget.text),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/devconsole');
                    },
                  )
                : Container()
          ],
        ),
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        body: Center(
            child: Container(
                padding: EdgeInsets.all(10),
                child: ScrollConfiguration(
                  behavior: CustomOverscroll(),
                  child: ListView(
                    children: settingsWidgets,
                  ),
                ))));
  }
}
