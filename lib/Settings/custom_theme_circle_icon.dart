import 'package:flutter/material.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'dart:math' as math;

import 'package:skymobile/Settings/theme_color_manager.dart';

class ThemeIcon extends CustomPainter {
  ThemeIcon();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(Rect.fromCircle(center:Offset(size.width/2,size.height/2),radius: 15), math.pi/2, math.pi, false, customPaint(0));
    canvas.drawArc(Rect.fromCircle(center:Offset(size.width/2,size.height/2),radius: 15), math.pi/2 * 3, math.pi, false, customPaint(1));
  }

  Paint customPaint(int i){
    Paint paint = Paint();
    paint.color = i == 0 ? themeManager.getColor(TypeOfWidget.text) : themeManager.getColor(TypeOfWidget.button);
    paint.isAntiAlias = true;
    paint.strokeWidth = 10;
    return paint;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
