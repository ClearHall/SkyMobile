import 'package:skymobile/HelperUtilities/DataPersist/json_saver.dart';
import 'package:skymobile/HelperUtilities/global.dart';

class SkyVars {
  static JSONSaver skyVarsJsonSaver =
      JSONSaver(FilesAvailable.consoleOnlyVariables);

  static final Map<String, String> skyVarsDefault = {
    'version': '2',
    'permdev': 'false',
    'iconchangesupport': 'false',
    'developeraccounts': 'false',
    'neiceban': 'false'
  };

  static Map<String, String> skyVars = {
    'version': '2',
    'permdev': 'false',
    'iconchangesupport': 'false',
    'developeraccounts': 'false',
    'neiceban': 'false'
  };

  static saveVars() async {
    try {
      await skyVarsJsonSaver.saveListData(skyVars);
    } catch (e) {
      print(e);
    }
  }

  static getVars() async {
    var retriev = await skyVarsJsonSaver.readListData();
    if (!(retriev is int) && retriev != null) {
      skyVars = Map.from(retriev);
    } else {
      saveVars();
    }
  }

  static bool modifyVar(String a, dynamic b) {
    neiceban = skyVars['neiceban'] == 'true';
    if (skyVars.containsKey(a)) {
      skyVars[a] = b.toString();
      saveVars();
      return true;
    } else {
      return false;
    }
  }

  static dynamic getVar(String a) {
    String got = skyVars[a];
    if (got == 'true' || got == 'false') {
      return got == 'true';
    } else if (int.tryParse(got) != null) {
      return int.parse(got);
    } else {
      return got;
    }
  }
}
