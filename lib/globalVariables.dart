import 'SkywardScraperAPI/SkywardAPICore.dart';
import 'SkywardScraperAPI/SkywardAPITypes.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/辅助/jsonSaver.dart';

SkywardAPICore skywardAPI;
String currentSessionIdentifier;
List<Term> terms;
List<GridBox> gradeBoxes;
List<AssignmentsGridBox> assignmentsGridBoxes;
List<AssignmentInfoBox> assignmentInfoBoxes;
List<SchoolYear> historyGrades;

List<String> termIdentifiersCountingTowardGPA = ['PR1', 'S1', 'S2'];

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

List<double> getAveragesOfTermsCountingTowardGPA(List<SchoolYear> enabledSchoolYears){
  List<double> averagesRespeciveOfTerms = [];
  for(String term in termIdentifiersCountingTowardGPA){
    double finalGrade = 0;
    double credits = 0;
    for(SchoolYear schoolYear in enabledSchoolYears){
      if(schoolYear.terms.contains(Term(term, null))) {
        int indexOfTerm = schoolYear.terms.indexOf(Term(term,null));
        for (Class classYear in schoolYear.classes) {
          int addOnPoints = determinePointsFromClassLevel(classYear.classLevel ?? ClassLevel.Regular);
          if (addOnPoints >= 0) {
            double attemptedDoubleParse = double.tryParse(classYear.grades[indexOfTerm]);
            if(attemptedDoubleParse != null){
              finalGrade += attemptedDoubleParse + addOnPoints;
              credits += classYear.credits ?? 1.0;
            }
          }
        }
      }
    }
    if(credits == 0) averagesRespeciveOfTerms.add(0); else averagesRespeciveOfTerms.add(finalGrade/credits);
  }
  return averagesRespeciveOfTerms;
}

int determinePointsFromClassLevel(ClassLevel level){
  switch(level){
    case ClassLevel.AP:
      return 10;
    case ClassLevel.PreAP:
      return 5;
    case ClassLevel.Regular:
      return 0;
    case ClassLevel.None:
      return -1;
    default:
      return -1;
  }
}


gpaCalculatorSettingsSaveForCurrentSession() async{
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.gpaCalcAttributes);
  var retrievedFromStorage = await jsonSaver.readListData();
  if(retrievedFromStorage is Map){
    retrievedFromStorage[currentSessionIdentifier] = historyGrades;
    jsonSaver.saveListData(retrievedFromStorage);
  }else{
    Map newMap = Map();
    newMap[currentSessionIdentifier] = historyGrades;
    jsonSaver.saveListData(newMap);
  }
}

gpaCalculatorSettingsReadForCurrentSession() async{
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.gpaCalcAttributes);
  var retrievedFromStorage = await jsonSaver.readListData();
  if(retrievedFromStorage is Map && retrievedFromStorage.containsKey(currentSessionIdentifier)) {
    return List<SchoolYear>.from(retrievedFromStorage[currentSessionIdentifier]);
  }else{
    gpaCalculatorSettingsSaveForCurrentSession();
    return historyGrades;
  }
}