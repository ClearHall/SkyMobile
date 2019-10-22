import 'package:skymobile/HelperUtilities/globalVariables.dart';
import 'package:skyscrapeapi/skywardAPITypes.dart';
import 'package:skymobile/HelperUtilities//jsonSaver.dart';
import 'types.dart';

Map<String, dynamic> extraGPASettings = Map.fromIterables([
  'Class Level Worth',
  'Advanced 4.0 GPA',
  'Use 4.33 for A+',
  'Weighted 4.0',
], [
  Map.fromIterables([
    'description',
    'option'
  ], [
    'Change how many points are added for different class levels.',
    {"AP": 10, "PreAP": 5, "Regular": 0}
  ]),
  Map.fromIterables([
    'description',
    'option'
  ], [
    '4.0 GPA is usually calculated with the Advanced mode on. It calculates your GPA with + and - and more advanced intervals. All the intervals are from College Board.',
    true
  ]),
  Map.fromIterables(['description', 'option'],
      ['College Board uses 4.0 for A+, but sometimes 4.33 is used.', false]),
  Map.fromIterables([
    'description',
    'option'
  ], [
    'Weighted GPA. Your district may or may not send weighted GPA to colleges. Fort Bend ISD sends unweighted.',
    false
  ])
]);

double get40Scale(List<SchoolYear> enabledSchoolYears) {
  _getClassLevelSettings();
  bool shouldAdd = extraGPASettings['Weighted 4.0']['option'];
  GPA40ScaleRangeList rangeList = GPA40ScaleRangeList(
      advanced: extraGPASettings['Advanced 4.0 GPA']['option'],
      will433: extraGPASettings['Use 4.33 for A+']['option']);
  List<double> averagesRespeciveOfTerms = [];
  for (String term in termIdentifiersCountingTowardGPA) {
    double finalGrade = 0;
    double credits = 0;
    for (SchoolYear schoolYear in enabledSchoolYears) {
      if (schoolYear.terms.contains(Term(term, null))) {
        int indexOfTerm = schoolYear.terms.indexOf(Term(term, null));
        for (Class classYear in schoolYear.classes) {
          int addOnPoints =
              classLevels[classYear.classLevel ?? ClassLevel.Regular];
          if (addOnPoints >= 0) {
            if (indexOfTerm < classYear.grades.length) {
              double attemptedDoubleParse =
                  double.tryParse(classYear.grades[indexOfTerm]);
              if (attemptedDoubleParse != null) {
                double creditHrs = (classYear.credits ?? 1.0) * 3.0;
                double x =
                    (rangeList.findGPAScale(attemptedDoubleParse.toInt()) +
                        ((shouldAdd ? addOnPoints : 0) / 10.0));
                finalGrade += x * creditHrs;
                credits += creditHrs;
              }
            }
          }
        }
      }
    }
    averagesRespeciveOfTerms.add(credits > 0 ? finalGrade / credits : null);
  }
  int ln = averagesRespeciveOfTerms.length;
  return averagesRespeciveOfTerms.fold(0.0, (v, e) {
        if (e != null)
          return v + e;
        else
          ln--;
        return v;
      }) /
      ln;
}

List<double> getAveragesOfTermsCountingTowardGPA100PointScale(
    List<SchoolYear> enabledSchoolYears) {
  _getClassLevelSettings();
  List<double> averagesRespeciveOfTerms = [];
  for (String term in termIdentifiersCountingTowardGPA) {
    double finalGrade = 0;
    double credits = 0;
    for (SchoolYear schoolYear in enabledSchoolYears) {
      if (schoolYear.terms.contains(Term(term, null))) {
        int indexOfTerm = schoolYear.terms.indexOf(Term(term, null));
        for (Class classYear in schoolYear.classes) {
          int addOnPoints =
              classLevels[classYear.classLevel ?? ClassLevel.Regular];
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

Map<ClassLevel, int> classLevels = Map.fromIterables(ClassLevel.values, [
  extraGPASettings['Class Level Worth']['Regular'],
  extraGPASettings['Class Level Worth']['PreAP'],
  extraGPASettings['Class Level Worth']['AP'],
  -1
]);

_saveClassLevelSettings() async {
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.classLevelValues);
  List cLK = classLevels.keys.toList();
  Map convertedToStringString = Map.fromIterables(
      List.generate(classLevels.keys.length, (e) => cLK[e].toString()),
      classLevels.values);
  await jsonSaver.saveListData(convertedToStringString);
}

_getClassLevelSettings() async {
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.classLevelValues);
  var _result = await jsonSaver.readListData();
  if (_result.runtimeType == Map) {
    classLevels = _result;
  } else {
    _saveClassLevelSettings();
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

getExtraGPASettings() async {
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.gpaExtraSettings);
  var retrieved = await jsonSaver.readListData();
  if (retrieved is Map) {
    extraGPASettings = retrieved;
  } else {}
}

saveExtraGPASettings() async {
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.gpaExtraSettings);
  jsonSaver.saveListData(extraGPASettings);
}
