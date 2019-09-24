import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'SkywardAPITypes.dart';
import 'dart:convert';

class HistoryAccessor {
  static final _termJsonDeliminater =
      "sff.sv('sf_gridObjects',\$.extend((sff.getValue('sf_gridObjects') || {}), ";

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
        if (elem.text.contains(_termJsonDeliminater)) {
          var needToDecodeJson = elem.text.substring(
              elem.text.indexOf(_termJsonDeliminater) +
                  _termJsonDeliminater.length,
              elem.text.length - 4);

          while (needToDecodeJson.contains("'gradeGrid")) {
            int indOfGradeGrid = needToDecodeJson.indexOf("'gradeGrid") - 1;
            needToDecodeJson =
                needToDecodeJson.replaceFirst("'", "\"", indOfGradeGrid);
            needToDecodeJson =
                needToDecodeJson.replaceFirst("'", "\"", indOfGradeGrid);
          }

          var mapOfFutureParsedHTML = json.decode(needToDecodeJson);

          return (getLegacyGrades(mapOfFutureParsedHTML));
        }
      }
    }
  }

  static getLegacyGrades(Map<String, dynamic> retrieved) {
    List<SchoolYear> schoolYears = [];

    for (Map school in retrieved.values) {
      List mapsOfGrid = school['tb']['r'];
      SchoolYear currentYear;
      List<Term> tempTerms = [];
      for (Map elem in mapsOfGrid) {
        List cArray = elem['c'];
        String firstElemType = cArray.first['h'];

        Document docFrag = Document.html("""<html>
                                              <head></head>
                                              <body>$firstElemType </body>
                                             </html>""");

        String type = 'terms';
        String className;
        if (docFrag.querySelector('div') != null) {
          type = 'schoolyear';
          currentYear = SchoolYear();
          currentYear.description = docFrag.querySelector('div').text;
          currentYear.classes = List();
          if (currentYear != null) schoolYears.add(currentYear);
          tempTerms = [];
        } else if (!firstElemType.contains('style="vertical-align:bottom"')) {
          type = 'classandgrades';
          className = docFrag.querySelector('body').text;
          currentYear.classes.add(Class(className));
          currentYear.classes.last.grades = List<String>();
        }

        if (type != 'schoolyear')
          for (int i = 0; i < cArray.length; i++) {
            Map x = cArray[i];
            Document curr = Document.html("""<html>
                                              <head></head>
                                              <body>${x.values.first}</body>
                                             </html>""");
            if (type == 'terms') {
              var attrElem = curr.querySelector('span')?? curr.querySelector('body');
              tempTerms.add(Term(attrElem.text, attrElem.attributes['tooltip']));
            } else {
              currentYear.classes.last.grades.add(curr.querySelector('body').text);
            }
          }
        if(type == 'terms') currentYear.terms = tempTerms;
      }
    }
    return schoolYears;
  }
}
