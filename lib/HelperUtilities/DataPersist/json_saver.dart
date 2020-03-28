import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skyscrapeapi/data_types.dart';

import '../account_types.dart';

class JSONSaver {
  FilesAvailable fileName;

  JSONSaver(this.fileName);

  getLocalDirectoryPath() async {
    final dir = await getApplicationDocumentsDirectory();

    return dir.path;
  }

  getFile() async {
    final path = await getLocalDirectoryPath();
    return File('$path/${fileName.toString()}.skymobileDat');
  }

  doesFileExist() async {
    final path = await getLocalDirectoryPath();
    return await File('$path/${fileName.toString()}.skymobileDat').exists();
  }

  saveListData(dynamic savingList) async {
    final File file = await getFile();
    return file.writeAsString(jsonEncode(savingList));
  }

  Future<dynamic> readListData() async {
    try {
      final File file = await getFile();
      if(!file.existsSync()) {
        print(file.path + ' does not exist!');
        return null;
      }
      String contents = await file.readAsString();
      var retrievedJSONCoded = jsonDecode(contents);

      if (retrievedJSONCoded is List) {
        List listOfTargetedObject = [];
        for (var retrieved in retrievedJSONCoded)
          if (fileName == FilesAvailable.accounts) {
            listOfTargetedObject.add(Account.fromJson(retrieved));
          } else if (fileName == FilesAvailable.gpaSelectedTerms) {
            listOfTargetedObject.add(retrieved);
          }
        return listOfTargetedObject;
      }

      if (retrievedJSONCoded is Map) {
        Map mapOfTargetedObject = Map();
        if (fileName == FilesAvailable.gpaCalculatorSettings) {
          retrievedJSONCoded.forEach((key, val) {
            List newVal = [];
            for (var retrieved in val) {
              SchoolYear schoolYear = SchoolYear.fromJson(retrieved);
              newVal.add(schoolYear);
            }
            mapOfTargetedObject[key] = newVal;
          });
        } else if (fileName == FilesAvailable.previousDistrict) {
          return SkywardDistrict.fromJson(retrievedJSONCoded);
        } else if (fileName == FilesAvailable.settings) {
          retrievedJSONCoded['Custom Theme']['option'] = ColorTheme.fromJson(retrievedJSONCoded['Custom Theme']['option']);
          mapOfTargetedObject = retrievedJSONCoded;
        }else
          mapOfTargetedObject = retrievedJSONCoded;
        return mapOfTargetedObject;
      }
    } catch (e) {
      return 0;
    }
  }
}

enum FilesAvailable {
  /// Stores stored account files
  accounts,

  /// Stores GPA Calculator class settings
  gpaCalculatorSettings,

  /// GPA Terms that have been selected that count toward GPA
  gpaSelectedTerms,

  /// GPA extra modifiers
  gpaExtraSettings,

  /// The district previously stored
  previousDistrict,

  /// Settings like biometrics and theme
  settings,

  /// Previously saved account if option is enabled in settings
  previouslySavedAccount,

  firstTime,

  consoleOnlyVariables,
}
