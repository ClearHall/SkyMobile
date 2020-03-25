import 'package:skyscrapeapi/sky_core.dart';
import 'package:skyscrapeapi/data_types.dart';
import '../Settings/theme_color_manager.dart';
import 'package:flutter/material.dart';

String currentSessionIdentifier;
String currentChild;
User account;
bool neiceban = true;
ThemeManager themeManager = ThemeManager();

Map<String, dynamic> settings = Map.fromIterables([
  'Biometric Authentication',
  'Theme',
  'Custom Theme',
  'Dark Mode',
  'Re-Authenticate With Biometrics',
  'Automatically Re-Load Last Saved Session',
  'Default to Account Chooser',
  'Hidden Empty Assignment Properties',
  'Hierarchical Grades'
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
    'SkyMobile will block your grades from being seen in the app switcher. Though, if you want an extra layer of security, you can force biometric authentication when you come back into the app.',
    true
  ]),
  Map.fromIterables([
    'description',
    'option'
  ], [
    'Reload last saved session if there is one. This will skip the login screen altogether if there is a session saved.',
    false
  ]),
  Map.fromIterables(['description', 'option'],
      ['Show account retriever as default instead of login screen.', false]),
  Map.fromIterables(['description', 'option'],
      ['Hides assignment property if the description is empty.', true]),
  Map.fromIterables(['description', 'option'],
      ['Displays assignment grades as a hiearchy.', true]),
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

int indexOfKey(List<Widget> data, Key key) {
  return data.indexWhere((Widget d) => d.key == key);
}