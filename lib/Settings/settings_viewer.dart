import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skymobile/ExtraViewPackages/biometric_blur_view.dart';
import 'package:skymobile/ExtraViewPackages/hunty_dialogs.dart';
import 'package:skymobile/HelperUtilities/json_saver.dart';
import 'package:skymobile/HelperUtilities/manage_sky_vars.dart';
import 'package:skymobile/Settings/settings_widget_generator.dart';
import 'package:skymobile/main.dart';
import 'theme_color_manager.dart';
import 'package:skymobile/HelperUtilities/global.dart';

void saveSettingsData() {
JSONSaver jsonSaver = JSONSaver(FilesAvailable.settings);
jsonSaver.saveListData(settings);
int i = settings['Theme']['option'].values.toList().indexOf(true);
themeManager.currentTheme = ThemeManager.colorNameToThemes.keys.toList()[
ThemeManager.colorNameToThemes.values
    .toList()
    .indexOf(settings['Theme']['option'].keys.toList()[i])];
}

class SettingsViewer extends StatefulWidget {
  SettingsViewer({Key key}) : super(key: key);

  @override
  _SettingsViewerState createState() => _SettingsViewerState();
}

class _SettingsViewerState extends BiometricBlur<SettingsViewer> {

  @override
  Widget generateBody(BuildContext context) {
    List<Widget> settingsWidgets = [];
    for (String k in settings.keys) {
      if (settings[k]['option'] is Map)
        settingsWidgets.add(
            SettingsWidgetGenerator.generateListSelectableSettings(
                k, settings[k],
                maxAmountSelectable: 1, run: (){
                  setState(() {
                    saveSettingsData();
                  });
            }));
      else
        settingsWidgets.add(
          SettingsWidgetGenerator.generateSingleSettingsWidget(k, settings[k],
              run: (){
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
                            '\nSkyMobile will disable authentication for you.',
                        buttonText: 'Ok'));
                setState(() {
                  settings['Biometric Authentication']['option'] = false;
                });
              }
            }
          }),
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
          child: ListView(
            children: settingsWidgets,
          ),
        ));
  }
}
