import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'SkywardAPITypes.dart';
import 'dart:convert';

class HistoryAccessor{
  static final _termJsonDeliminater = "sff.sv('sf_gridObjects',\$.extend((sff.getValue('sf_gridObjects') || {}), ";

  static getGradebookHTML(Map<String, String> codes, String baseURL) async {
    final String gradebookURL = baseURL + 'sfacademichistory001.w';
    final postReq = await http.post(gradebookURL, body: codes);
    return postReq.body;
  }

  static parseGradebookHTML(String html) {
    var doc = Document.html(html);
    List<Element> elems = doc.querySelectorAll("script");

    for (Element elem in elems) {
      if (elem.text.contains('sff.')) {
        if (elem.text.contains(
            _termJsonDeliminater)) {
          var needToDecodeJson =
          elem.text.substring(elem.text.indexOf(_termJsonDeliminater) +
              _termJsonDeliminater.length, elem.text.length - 4);

          while(needToDecodeJson.contains("'gradeGrid")){
            int indOfGradeGrid = needToDecodeJson.indexOf("'gradeGrid") - 1;
            needToDecodeJson = needToDecodeJson.replaceFirst("'", "\"", indOfGradeGrid);
            needToDecodeJson = needToDecodeJson.replaceFirst("'", "\"", indOfGradeGrid);
          }

          print(needToDecodeJson);
          var mapOfFutureParsedHTML = json.decode(needToDecodeJson);

          for(var x in mapOfFutureParsedHTML.values)
            print(x);
        }
      }
    }
  }
}