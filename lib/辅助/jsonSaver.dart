import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'accountTypes.dart';
import 'package:skymobile/SkywardScraperAPI/SkywardAPITypes.dart';

class JSONSaver{
  FilesAvailable fileName;

  JSONSaver(this.fileName);

  getLocalDirectoryPath() async{
    final dir = await getApplicationDocumentsDirectory();

    return dir.path;
  }

  getFile() async{
    final path = await getLocalDirectoryPath();
    return File('$path/${fileName.toString()}.skymobileDat');
  }

  accountFileExists() async{
    final path = await getLocalDirectoryPath();
    return await File('$path/${fileName.toString()}.skymobileDat').exists();
  }

  saveListData(dynamic savingList) async{
    final File file = await getFile();
    return file.writeAsString(jsonEncode(savingList));
  }

  readListData() async{
    try{
      final File file = await getFile();
      String contents = await file.readAsString();
      var retrievedJSONCoded = jsonDecode(contents);

      if(retrievedJSONCoded is List){
        List listOfTargetedObject = [];
        for(var retrieved in retrievedJSONCoded)
        if(fileName == FilesAvailable.accounts){
          listOfTargetedObject.add(Account.fromJson(retrieved));
        }
        return listOfTargetedObject;
      }

      if(retrievedJSONCoded is Map){
        Map mapOfTargetedObject = Map();
        if(fileName == FilesAvailable.gpaCalcAttributes) {
          retrievedJSONCoded.forEach((key, val) {
            List newVal = [];
            for (var retrieved in val) {
              SchoolYear schoolYear = SchoolYear.fromJson(retrieved);
              newVal.add(schoolYear);
            }
            mapOfTargetedObject[key] = newVal;
          });
        }
        return mapOfTargetedObject;
      }
    } catch (e,s) {
      print(s);
      return 0;
    }
  }

}

enum FilesAvailable{
  accounts,
  gpaCalcAttributes
}