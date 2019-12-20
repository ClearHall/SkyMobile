import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:skymobile/ExtraViewPackages/biometric_blur_view.dart';
import 'package:skymobile/ExtraViewPackages/constant_visibile_scrollbar.dart';
import 'package:skymobile/GPACalculator/school_year.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/Settings/settings_widget_generator.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skyscrapeapi/data_types.dart';
import '../HelperUtilities/gpa_calculator_support_utils.dart';

class GPACalculatorSettings extends StatefulWidget {
  GPACalculatorSettings({Key key}) : super(key: key);

  @override
  _GPACalculatorSettingsState createState() => _GPACalculatorSettingsState();
}

class _GPACalculatorSettingsState extends BiometricBlur<GPACalculatorSettings> {
  Map<String, TextEditingController> mapEditable = Map();

  Row buildArrayOfSelectableTerms(List<String> stringList) {
    List<Widget> widgets = [];

    for (String term in stringList) {
      if (!term.contains('\n'))
        widgets.add(Container(
          child: ListTile(
            title: Text(
              "$term",
              style: TextStyle(
                  color: themeManager.getColor(TypeOfWidget.text),
                  fontSize: 20),
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: Icon(
                  termIdentifiersCountingTowardGPA.contains(term)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: themeManager.getColor(null)),
              onPressed: () {
                setState(() {
                  if (termIdentifiersCountingTowardGPA.contains(term)) {
                    termIdentifiersCountingTowardGPA.remove(term);
                  } else {
                    int index = stringList.indexOf(term);
                    for (int i = 0;
                    i < termIdentifiersCountingTowardGPA.length;
                    i++) {
                      if (stringList
                          .indexOf(termIdentifiersCountingTowardGPA[i]) >
                          index) {
                        termIdentifiersCountingTowardGPA.insert(i, term);
                        break;
                      }
                    }
                    if (!termIdentifiersCountingTowardGPA.contains(term))
                      termIdentifiersCountingTowardGPA.add(term);
                  }
                  saveTermsToRead();
                });
              },
            ),
          ),
        ));
    }
    List<Widget> first, second;
    first = [];
    second = [];
    for (int i = 0; i < widgets.length; i++) {
      if (i <= widgets.length / 2) {
        first.add(widgets[i]);
      } else {
        second.add(widgets[i]);
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Column(
              children: first,
            )),
        Expanded(
            child: Column(
              children: second,
            )),
      ],
    );
  }

  @override
  Widget generateBody(BuildContext context) {
    List<String> stringList = GPACalculatorSchoolYearState.getSelectableTermsString(GPACalculatorSchoolYearState.getEnabledHistGrades());
    List<Widget> widgets = [
      Container(
          child: Text(
            'Check the terms that will be used in GPA calculation',
            style: TextStyle(
                color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
          ),
          padding: EdgeInsets.only(left: 20, right: 20, top: 10)),
      Container(
        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 200),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color:
              themeManager.getColor(TypeOfWidget.subBackground),
              child: SingleChildScrollViewWithScrollbar(
                scrollbarColor: Colors.white30.withOpacity(0.75),
                scrollbarThickness: 8.0,
                child: SingleChildScrollView(
                    child: buildArrayOfSelectableTerms(stringList)),
              )),
        ),
      ),
      Container(
          child: Text(
            'Tick or change the settings depending on your district or college. Read descriptions carefully verify that the settings are correct.',
            style: TextStyle(
                color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
          ),
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10))
    ];
    for (String k in extraGPASettings.keys) {
      if (extraGPASettings[k]['option'] is Map) {
        widgets.add(SettingsWidgetGenerator.generateListSettingsWidget(
            k, extraGPASettings[k], mapEditable, run: () {
          setState(() {
            saveExtraGPASettings();
            mapEditable.forEach((k, controller) {
              controller.text = '';
            });
          });
        }));
      } else {
        widgets.add(SettingsWidgetGenerator.generateSingleSettingsWidget(
            k, extraGPASettings[k], run: () {
          saveExtraGPASettings();
        }));
      }
    }

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: themeManager.getColor(TypeOfWidget.text), size: 30),
          backgroundColor: themeManager.getColor(TypeOfWidget.background),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text('4.0 Scale Settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: themeManager.getColor(TypeOfWidget.text),
                    fontSize: 30,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Container(padding: EdgeInsets.only(left: 10, right: 10), child: ListView(children: widgets),)
        ));
  }
  //Widget _generateSettingsClickable(String setting, )
}
