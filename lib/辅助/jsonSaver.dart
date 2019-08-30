import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'accountTypes.dart';

class JSONSaver{
  static getLocalDirectoryPath() async{
    final dir = await getApplicationDocumentsDirectory();

    return dir.path;
  }

  static accountSaverFile() async{
    final path = await getLocalDirectoryPath();
    return File('$path/accounts.accDat');
  }

  static accountFileExists() async{
    final path = await getLocalDirectoryPath();
    return await File('$path/accounts.accDat').exists();
  }

  static saveAccountData(List<Account> acc) async{
    final File file = await accountSaverFile();
    List<String> keys = [];
    for(int i = 0; i < acc.length; i++){
      keys.add(i.toString());
    }
    Map<String, dynamic> accMap = Map.fromIterables(keys, acc);
    return file.writeAsString(jsonEncode(accMap));
  }

  static readAccountData() async{
    try{
      List<Account> accts = [];
      final File file = await accountSaverFile();
      String contents = await file.readAsString();
      Map<String, dynamic> accounts = jsonDecode(contents);
      for(Map avv in accounts.values){
        Account currentAcc = Account.fromJson(avv);
        accts.add(currentAcc);
      }
      return accts;
    } catch (e) {
      return 0;
    }
  }
}