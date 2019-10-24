import 'package:skyscrapeapi/skywardAPICore.dart';
import 'package:skyscrapeapi/skywardAPITypes.dart';
import '../Settings/themeColorManager.dart';
import 'package:flutter/material.dart';

SkywardAPICore skywardAPI;
String currentSessionIdentifier;
List<Term> terms;
List<GridBox> gradeBoxes;
List<AssignmentsGridBox> assignmentsGridBoxes;
List<AssignmentInfoBox> assignmentInfoBoxes;
List<SchoolYear> historyGrades;
ThemeManager themeManager = ThemeManager();

Map<String, dynamic> settings = Map.fromIterables([
  'Biometric Authentication',
  'Theme'
], [
  Map.fromIterables([
    'description',
    'option'
  ], [
    'Biometric authentication to protect your gradebook! Biometric authentication will only be required for logging into a saved account.',
    false
  ]),
  Map.fromIterables([
    'description',
    'option'
  ], [
    'Change the color scheme used for the app.',
    Map.fromIterables(
        List.generate(ThemeManager.defaultThemes.length, (i) {
          return ThemeManager.defaultThemes[i].primary.toString();
        }),
        List.generate(ThemeManager.defaultThemes.length, (i) {
          if (themeManager.currentTheme == ThemeManager.defaultThemes[i])
            return true;
          else
            return false;
        }))
  ])
]);

List<String> termIdentifiersCountingTowardGPA = ['S1', 'S2'];

Color getColorFrom(String grade) {
  if (grade != null && grade != '' && double.tryParse(grade) != null) {
    double green = (double.parse(grade) * 2.55 / 255);

    if (green > 1.0) green = 1.0;

    double red = (1.0 - green) * 6.0;

    if (red > 1.0) red = 1.0;

    return Color.fromARGB(255, (red * 255).floor(), (green * 255).floor(), 0);
  }
  return Color.fromARGB(255, 0, (0.8471 * 255).round(), (0.8039 * 255).round());
}
