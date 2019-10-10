import 'package:skymobile/SkyMobileHelperUtilities/globalVariables.dart';
import 'package:skyscrapeapi/skywardAPITypes.dart';
import 'package:skymobile/SkyMobileHelperUtilities/jsonSaver.dart';

List<double> getAveragesOfTermsCountingTowardGPA100PointScale(
    List<SchoolYear> enabledSchoolYears) {
  List<double> averagesRespeciveOfTerms = [];
  for (String term in termIdentifiersCountingTowardGPA) {
    double finalGrade = 0;
    double credits = 0;
    for (SchoolYear schoolYear in enabledSchoolYears) {
      if (schoolYear.terms.contains(Term(term, null))) {
        int indexOfTerm = schoolYear.terms.indexOf(Term(term, null));
        for (Class classYear in schoolYear.classes) {
          int addOnPoints = determinePointsFromClassLevel(
              classYear.classLevel ?? ClassLevel.Regular);
          if (addOnPoints >= 0) {
            if (indexOfTerm < classYear.grades.length) {
              double attemptedDoubleParse =
                  double.tryParse(classYear.grades[indexOfTerm]);
              if (attemptedDoubleParse != null) {
                finalGrade += (attemptedDoubleParse + addOnPoints) *
                    (classYear.credits ?? 1.0);
                credits += classYear.credits ?? 1.0;
              }
            }
          }
        }
      }
    }
    averagesRespeciveOfTerms.add(credits > 0 ? finalGrade / credits : null);
  }
  return averagesRespeciveOfTerms;
}

int determinePointsFromClassLevel(ClassLevel level) {
  //TODO: Let user decide the number of points to add for each level!
  switch (level) {
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

gpaCalculatorSettingsSaveForCurrentSession() async {
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.gpaCalculatorSettings);
  var retrievedFromStorage = await jsonSaver.readListData();
  if (retrievedFromStorage is Map) {
    retrievedFromStorage[currentSessionIdentifier] = historyGrades;
    jsonSaver.saveListData(retrievedFromStorage);
  } else {
    Map newMap = Map();
    newMap[currentSessionIdentifier] = historyGrades;
    jsonSaver.saveListData(newMap);
  }
}

gpaCalculatorSettingsReadForCurrentSession() async {
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.gpaCalculatorSettings);
  var retrievedFromStorage = await jsonSaver.readListData();
  if (retrievedFromStorage is Map &&
      retrievedFromStorage.containsKey(currentSessionIdentifier)) {
    return List<SchoolYear>.from(
        retrievedFromStorage[currentSessionIdentifier]);
  } else {
    gpaCalculatorSettingsSaveForCurrentSession();
    return historyGrades;
  }
}

getTermsToRead() async {
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.gpaSelectedTerms);
  var retrievedFromStorage = await jsonSaver.readListData();
  if (retrievedFromStorage is List) {
    termIdentifiersCountingTowardGPA = List<String>.from(retrievedFromStorage);
  } else {
    saveTermsToRead();
  }
}

saveTermsToRead() async {
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.gpaSelectedTerms);
  await jsonSaver.saveListData(termIdentifiersCountingTowardGPA);
}