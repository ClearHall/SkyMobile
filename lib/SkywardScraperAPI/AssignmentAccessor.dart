import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'SkywardAPITypes.dart';

class AssignmentAccessor {
  static getAssignmentsHTML(Map<String, String> codes, String baseURL,
      String corNum, String bkt) async {
    codes['action'] = 'viewGradeInfoDialog';
    codes['fromHttp'] = 'yes';
    codes['ishttp'] = 'true';
    codes['corNumId'] = corNum;
    codes['bucket'] = bkt;

    final String gradebookURL = baseURL + 'sfgradebook001.w';

    var response = await http.post(gradebookURL, body: codes);

    return response.body;
  }

  static getAssignmentsDialog(String assignmentPageHTML) {
    String newString = assignmentPageHTML.split("<![CDATA[")[1].split("]]>")[0];
    var doc = DocumentFragment.html(newString);
    List<AssignmentsGridBox> gridBoxes = [];
    List<Element> tdElems = doc.querySelectorAll('td');
    List<Element> showAssignmentIDVal =
        doc.querySelectorAll('#showAssignmentInfo');
    for (int i = 0; i < tdElems.length; i++) {
      Element tdElem = tdElems[i];
      if (tdElem.classes.contains('nWp') && tdElem.classes.contains('noLBdr')) {
        String weightedText =
            tdElem.children.isNotEmpty ? tdElem.children[1].text : null;
        gridBoxes.add(CategoryHeader(
            tdElem.text.substring(
                0,
                weightedText != null
                    ? tdElem.text.indexOf(weightedText)
                    : tdElem.text.length),
            weightedText,
            tdElems[i + 1].text,
            tdElems[i + 3].text,
            tdElems[i + 2].text));
        i = i + 4;
      } else if (tdElem.attributes['scope'] == 'row' &&
          tdElem.text.trim().isNotEmpty) {
        if (tdElem.attributes.containsKey('nPtb')) {
          gridBoxes.add(CategoryHeader(
              tdElem.text, null, null, null, tdElems[i + 1].text));
          i = i + 2;
        } else if (tdElem.classes.contains('aTop')) {
          gridBoxes.add(CategoryHeader(tdElem.children[0].text, null,
              tdElems[i + 1].text, null, tdElems[i + 2].text));
          i = i + 3;
        } else if (tdElem.classes.isEmpty &&
            !tdElem.attributes.containsKey('style') &&
            tdElem.attributes['style'] != 'padding-right:4px') {
          Element assignment = showAssignmentIDVal.removeAt(_getIndexOfAssignmentFromNameAndElement(
              showAssignmentIDVal, tdElems[i + 1].text));

          List<String> attemptRetrieve = [
            tdElems[i + 2].text,
            tdElems[i + 4].text,
            tdElems[i + 3].text
          ];
          String intGrade = _getIntInd(attemptRetrieve);
          String decimalGrade = _getDecimalInd(attemptRetrieve);

          gridBoxes.add(Assignment(
            assignment.attributes['data-sid'],
            assignment.attributes['data-aid'],
            assignment.attributes['data-gid'],
            tdElem.text,
            tdElems[i + 1].text,
            intGrade,
            attemptRetrieve[0],
            decimalGrade,
          ));
          i = i + 5;
        }
      }
    }
    gridBoxes.removeAt(0);
    return gridBoxes;
  }

  static String _getDecimalInd(List<String> list) {
    for (String val in list) {
      if (double.tryParse(val) != null) {
        list.remove(val);
        return val;
      }
    }
  }

  static String _getIntInd(List<String> list) {
    for (String val in list) {
      if (int.tryParse(val) != null) {
        list.remove(val);
        return val;
      }
    }
  }

  static _getIndexOfAssignmentFromNameAndElement(
      List<Element> elems, String name) {
    for (int i = 0; i < elems.length; i++) {
      if (elems[i].text == name) {
        return i;
      }
    }
  }
}
