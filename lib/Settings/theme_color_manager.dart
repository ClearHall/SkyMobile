import 'package:flutter/material.dart';
import 'package:skymobile/HelperUtilities/global.dart';

class ThemeManager {
  static List<ColorTheme> defaultThemes = [
    ColorTheme(Colors.green, Colors.purple),
    ColorTheme(Colors.lightBlue, Colors.deepPurple),
    ColorTheme(Colors.yellow, Colors.blue),
    ColorTheme(Colors.orange, Colors.blue),
    ColorTheme(Colors.teal, Colors.brown)
  ];
  static Map<ColorTheme, String> colorNameToThemes = Map.fromIterables(
      defaultThemes,
      ['Purpulish Green', 'Purple Shadows', 'Golden Shimmer', 'Dark Orange', 'Albon\'s Sea']);
  ColorTheme currentTheme =
      defaultThemes[3]; //ColorTheme(Colors.orange, Colors.blue);
  List<ColorTheme> userDefined = [];

  addTheme(Color p, Color s) {
    userDefined.add(ColorTheme(p, s));
  }

  shouldUseAlbonsTheme(){
    return defaultThemes.indexOf(currentTheme) == 4;
  }

  Color getColor(TypeOfWidget x) {
    switch (x) {
      case TypeOfWidget.background:
        return settings['Dark Mode']['option'] ? Colors.black : Colors.white;
      case TypeOfWidget.subBackground:
        return shouldUseAlbonsTheme() ? currentTheme.primary.shade900 : (settings['Dark Mode']['option'] ? Colors.white10 : Colors.white);
      case TypeOfWidget.text:
        return shouldUseAlbonsTheme() ? Colors.white : currentTheme.primary;
      case TypeOfWidget.button:
        return shouldUseAlbonsTheme() ? currentTheme.secondary.shade200 : currentTheme.secondary;
      case TypeOfWidget.subSubBackground:
        return shouldUseAlbonsTheme() ? currentTheme.secondary.shade400 : (settings['Dark Mode']['option'] ? Colors.white10 : Colors.white);
      default:
        return settings['Dark Mode']['option'] ? Colors.white : Colors.black;
    }
  }
}

enum TypeOfWidget { button, text, background, subBackground, subSubBackground }

class ColorTheme {
  MaterialColor  primary, secondary;

  ColorTheme(this.primary, this.secondary);
}
