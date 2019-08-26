import 'SkywardScraperAPI/SkywardAPICore.dart';
import 'SkywardScraperAPI/SkywardAPITypes.dart';
import 'package:flutter/material.dart';

SkywardAPICore skywardAPI;
List<Term> terms;
List<GridBox> gradeBoxes;
List<AssignmentsGridBox> assignmentsGridBoxes;
List<AssignmentInfoBox> assignmentInfoBoxes;

Color getColorFrom(String grade){
  if(grade != null && grade != '' && double.tryParse(grade) != null){
    double green = (double.parse(grade) * 2.55 / 255);

    if(green > 1.0) green = 1.0;

    double red = (1.0 - green) * 6.0;

    if(red > 1.0) red = 1.0;

    return Color.fromARGB(255, (red * 255).floor(), (green * 255).floor(), 0);
  }
  return Color.fromARGB(255, 0, (0.8471 * 255).round(), (0.8039 * 255).round());
}