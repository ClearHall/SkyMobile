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
    var doc = DocumentFragment.html(assignmentPageHTML);
    List<AssignmentsGridBox> gridBoxes = [];
    Element table =
        doc.querySelector('table[id*=grid_stuAssignmentSummaryGrid]');
    List<String> headers = [];
    List<Element> elementsInsideTable =
        table.querySelector('tbody').querySelectorAll('tr');

    if (headers.isEmpty) {
      List<Element> elems = table.querySelector('thead').querySelectorAll('th');
      for (Element header in elems) {
        headers.add(header.text);
      }
    }

    for(Element row in elementsInsideTable){
      List<Element> tdVals = row.querySelectorAll('td');
      List<String> attributes = [];
      if(row.classes.contains('sf_Section') && row.classes.contains('cat')){
        CategoryHeader catHeader = CategoryHeader(null, null, null);
        for(Element td in tdVals){
          if(td.classes.contains('nWp') && td.classes.contains('noLBdr')){
            Element weighted = td.querySelector('span');
            catHeader.weight = weighted != null ? weighted.text : null;
            attributes.add(td.text.substring(0, weighted != null ? td.text.indexOf(weighted.text) : td.text.length));
          }else{
            attributes.add(td.text);
          }
        }
        for(int i = attributes.length; i < headers.length; i++){
          attributes.add("");
        }
        catHeader.catName = attributes[1];
        catHeader.attributes = Map.fromIterables(headers, attributes);
        gridBoxes.add(catHeader);
      }else{
        Element assignment = row.querySelector('#showAssignmentInfo');
        for(Element td in tdVals) {
          attributes.add(td.text);
        }
        if(assignment != null)
          gridBoxes.add(Assignment(assignment.attributes['data-sid'], assignment.attributes['data-aid'], assignment.attributes['data-gid'], attributes[1], Map.fromIterables(headers, attributes)));
        else {
          for(int i = attributes.length; i < headers.length; i++){
            attributes.add("");
          }
          gridBoxes.add(Assignment(null, null, null, attributes.first,
              Map.fromIterables(headers, attributes)));
        }
      }
    }
    return gridBoxes;
  }
}
