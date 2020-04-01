import 'package:flutter/material.dart';
import 'package:skymobile/HelperUtilities/global.dart';

class ThemeManager {
  static List<ColorTheme> defaultThemes = [
    ColorTheme(Colors.green, Colors.purple),
    ColorTheme(Colors.lightBlue, Colors.deepPurple),
    ColorTheme(Colors.yellow, Colors.blue),
    ColorTheme(Colors.orange, Colors.blue),
    //ColorTheme(Colors.teal, Colors.brown)
  ];

  static Map<ColorTheme, String> colorNameToThemes =
      Map.fromIterables(defaultThemes, [
    'Purpulish Green',
    'Purple Shadows',
    'Golden Shimmer',
    'Dark Orange',
  ]);
  ColorTheme currentTheme =
      defaultThemes[3];

  Color getColor(TypeOfWidget x) {
    switch (x) {
      case TypeOfWidget.background:
        return settings['Dark Mode']['option'] ? Colors.black : Colors.white;
      case TypeOfWidget.subBackground:
        return (settings['Dark Mode']['option'] ? Colors.white10 : Colors.white);
      case TypeOfWidget.text:
        return currentTheme.primary.withOpacity(1.0);
      case TypeOfWidget.button:
        return currentTheme.secondary.withOpacity(1.0);
      case TypeOfWidget.subSubBackground:
        return (settings['Dark Mode']['option'] ? Colors.white10 : Colors.white);
      default:
        return settings['Dark Mode']['option'] ? Colors.white : Colors.black;
    }
  }
}

enum TypeOfWidget { button, text, background, subBackground, subSubBackground }

class ColorTheme {
  Color primary, secondary;

  ColorTheme.unset();
  ColorTheme(this.primary, this.secondary);

  ColorTheme.fromJson(Map<String, dynamic> json){
    primary = colorFromHash(json['primary']);
    secondary = colorFromHash(json['secondary']);
  }

  static Color colorFromHash(int hash){
    if(hash == null) return null;
    Color c = Color(hash);
    return c;
  }

  Map<String, dynamic> toJson() => {
    'primary': primary?.hashCode,
    'secondary': secondary?.hashCode,
  };

  bool unset(){
    return primary == null && secondary == null;
  }
}
