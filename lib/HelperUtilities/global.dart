import 'package:flutter/material.dart';
import 'package:skyscrapeapi/sky_core.dart';

import '../Settings/theme_color_manager.dart';

String currentSessionIdentifier;
String currentChild;
User account;
ThemeManager themeManager = ThemeManager();

Map<String, dynamic> settings = Map.fromIterables([
  'Biometric Authentication',
  'Theme',
  'Custom Theme',
  'Dark Mode',
  'Re-authenticate with Biometrics',
  'Fast Login',
  'Default to Account Chooser',
  'Hide Empty Assignment Properties',
  'Hierarchical Grades'
], [
  Map.fromIterables([
    'description',
    'option'
  ], [
    'Require biometric authentication for logging into saved accounts.',
    false
  ]),
  Map.fromIterables([
    'description',
    'option'
  ], [
    '',
    Map.fromIterables(
        ThemeManager.colorNameToThemes.values,
        List.generate(ThemeManager.colorNameToThemes.length, (i) {
          return false;
        }))
  ]),
  Map.fromIterables(['description', 'option'],
      ['Change the color scheme used for the app.', ColorTheme.unset()]),
  Map.fromIterables(['description', 'option'],
      ['Change between light mode and dark mode.', true]),
  Map.fromIterables([
    'description',
    'option'
  ], [
    'SkyMobile prevents grades from being seen in the app switcher. For an extra layer of security, you can force biometric authentication when the app is reopened.',
    true
  ]),
  Map.fromIterables([
    'description',
    'option'
  ], [
    'Use the last Skyward session if one exists, speeding up the login process.',
    false
  ]),
  Map.fromIterables(['description', 'option'],
      ['Show account retriever as default instead of login screen.', false]),
  Map.fromIterables(['description', 'option'],
      ['Hides assignment properties with empty descriptions.', true]),
  Map.fromIterables(['description', 'option'],
      ['Displays assignment grades as a hierarchy.', true]),
]);

List<String> termIdentifiersCountingTowardGPA = ['S1', 'S2'];

Color getColorFrom(String grade) {
  if (grade != 'NaN' && grade != 'Infinity' && grade != null && grade != '' && double.tryParse(grade) != null) {
    double green = (double.parse(grade) * 2.55 / 255);

    if (green > 1.0) green = 1.0;

    double red = (1.0 - green) * 6.0;

    if (red > 1.0) red = 1.0;

    return Color.fromARGB(255, (red * 255).floor(), (green * 255).floor(), 0);
  }
  return Color.fromARGB(255, 0, (0.8471 * 255).round(), (0.8039 * 255).round());
}

int indexOfKey(List<Widget> data, Key key) {
  return data.indexWhere((Widget d) => d.key == key);
}