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

  saveListData(List savingList) async{
    final File file = await getFile();
    List<String> keys = [];
    for(int i = 0; i < savingList.length; i++){
      keys.add(i.toString());
    }
    Map<String, dynamic> accMap = Map.fromIterables(keys, savingList);
    return file.writeAsString(jsonEncode(accMap));
  }

  readListData() async{
    try{
      List listOfTargetedObject = [];
      final File file = await getFile();
      String contents = await file.readAsString();
      Map<String, dynamic> retrievedJSONCoded = jsonDecode(contents);
      for(Map avv in retrievedJSONCoded.values){
        var currentAcc;
        switch (fileName) {
          case FilesAvailable.accounts:
            currentAcc = Account.fromJson(avv);
            break;
          case FilesAvailable.gpaCalcAttributes:
            currentAcc = SchoolYear.fromJson(avv);
            break;
          default:
            break;
        }
        listOfTargetedObject.add(currentAcc);
      }
      return listOfTargetedObject;
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