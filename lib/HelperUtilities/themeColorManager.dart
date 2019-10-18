import 'package:flutter/material.dart';

class ThemeManager{
  static bool isDarkTheme = true;

  List<ColorTheme> defaultThemes = [ColorTheme(Colors.lightGreen.shade500, Colors.deepPurple.shade400), ColorTheme(Colors.lightBlue, Colors.deepPurple.shade400), ColorTheme(Colors.yellow, Colors.blue)];
  ColorTheme currentTheme = ColorTheme(Colors.yellow, Colors.blue); //ColorTheme(Colors.orange, Colors.blue);
  List<ColorTheme> userDefined = [];

  addTheme(Color p, Color s){
    userDefined.add(ColorTheme(p, s));
  }

  Color getColor(TypeOfWidget x){
    switch(x){
      case TypeOfWidget.background:
        return isDarkTheme ? Colors.black : Colors.white;
      case TypeOfWidget.subBackground:
        return isDarkTheme ? Colors.white10 : Colors.black12;
      case TypeOfWidget.text:
        return currentTheme.primary;
      case TypeOfWidget.button:
        return currentTheme.secondary;
      default:
        return currentTheme.primary;
    }
  }
}

enum TypeOfWidget{
  button,
  text,
  background,
  subBackground
}

class ColorTheme{
  Color primary, secondary;

  ColorTheme(this.primary, this.secondary);
}