import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'SkywardAPITypes.dart';

class AssignmentAccessor{

  static getAssignmentsHTML(Map<String, String> codes, String baseURL) async {
    final String gradebookURL = baseURL + 'sfgradebook001.w';

    var response = await http.post(gradebookURL, body: codes);

    return response.body;
  }

  static getAssignmentsDialog(String assignmentPageHTML){
    String newString = assignmentPageHTML.split("</script>\n</td")[1].split("]]>")[0];
    var doc = DocumentFragment.html(newString);
    List<AssignmentsGridBox> gridBoxes = [];
    List<Element> tdElems = doc.querySelectorAll('td');
    List<Element> showAssignmentIDVal = doc.querySelectorAll('#showAssignmentInfo');
    for(int i = 0; i < tdElems.length; i++){
      Element tdElem = tdElems[i];
      if(tdElem.classes.contains('nWp') && tdElem.classes.contains('noLBdr')){
        String weightedText = tdElem.children[1].text;
        gridBoxes.add(CategoryHeader(tdElem.text.substring(0, tdElem.text.indexOf(weightedText)), weightedText, tdElems[i+1].text, tdElems[i+3].text, tdElems[i+2].text));
        i = i+4;
      }else if(tdElem.attributes['scope'] == 'row' && tdElem.text.trim().isNotEmpty){
        if(tdElem.text.contains('There are')){
          gridBoxes.add(Assignment(null, null, null, tdElem.text, null, null, null));
        }else {
          int ind = _getIndexOfAssignmentFromNameAndElement(
              showAssignmentIDVal, tdElems[i + 1].text);
          gridBoxes.add(Assignment(
              showAssignmentIDVal[ind].attributes['data-sid'],
              showAssignmentIDVal[ind].attributes['data-aid'], tdElem.text,tdElems[i + 1].text,
              tdElems[i + 2].text, tdElems[i + 4].text, tdElems[i + 3].text));
          i = i + 5;
        }
      }
    }
    return gridBoxes;
  }

  static _getIndexOfAssignmentFromNameAndElement(List<Element> elems, String name){
    for(int i = 0; i < elems.length; i++){
      if(elems[i].text == name) return i;
    }
  }

}