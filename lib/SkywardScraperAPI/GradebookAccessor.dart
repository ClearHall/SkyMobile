import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class GradebookAccessor {
  static List<String> sffData = [];
  /*
  This decoded json string is super weird. Look at initGradebookHTML if you need to understand it.
   */
  static List termElements = [];
  static List gradesElements = [];
  static final _termJsonDeliminater = "sff.sv('sf_gridObjects',\$.extend((sff.getValue('sf_gridObjects') ";

  static getGradebookHTML(Map<String, String> codes, String baseURL) async {
    final String gradebookURL = baseURL + 'sfgradebook001.w';
    final postReq = await http.post(gradebookURL, body: codes);
    initGradebookAndGradesHTML(postReq.body);
    return postReq.body;
  }

  static getTermsFromDocCode() {
    var terms = [];
    terms = _detectTermsFromScriptByParsing();
    if (terms != null)
      return terms;
    else
      return null;
  }

  //TODO: Implement server quick scrape assignments algorithm from sff.sv() script code.

  static getGradeBoxesFromDocCode(){
    var gradeBoxes = [];
    gradeBoxes = _scrapeGradeBoxesFromSff();
    if (gradeBoxes != null)
      return gradeBoxes;
    else
      return null;
  }

  static List<GradeBox> _scrapeGradeBoxesFromSff() {
    List<GradeBox> gradeBoxes = [];
    for (var sffBrak in gradesElements) {
      for(var c in sffBrak['c']){
        
        var cDoc = DocumentFragment.html(c['h']);
        Element gradeElem = cDoc.querySelector('#showGradeInfo');
        if(gradeElem != null){
          gradeBoxes.add(GradeBox(gradeElem.attributes['data-cni'], Term(gradeElem.attributes['data-lit'], gradeElem.attributes['data-bkt']), gradeElem.text, gradeElem.attributes['data-sid']));
        }else if (cDoc.text != ''){

        }
      }
    }
    return gradeBoxes;
  }

  static void initGradebookAndGradesHTML(String html){
    Document doc = parse(html);

    List<Element> elems = doc.querySelectorAll("script");

    for (Element elem in elems) {
      if (elem.text.contains('sff.')) {

        if (elem.text.contains(
            _termJsonDeliminater)) {
          var needToDecodeJson =
          elem.text.substring(elem.text.indexOf(_termJsonDeliminater) + _termJsonDeliminater.length, elem.text.length - 5);
          needToDecodeJson =
              needToDecodeJson.substring(needToDecodeJson.indexOf(':') + 1);
          var mapOfFutureParsedHTML = jsonDecode(needToDecodeJson);

          if(termElements.isEmpty) {
            termElements = mapOfFutureParsedHTML['th']['r'][0]['c'];
          }
          if(gradesElements.isEmpty) {
            gradesElements = mapOfFutureParsedHTML['tb']['r'];
          }
        }
      }
    }

  }

  static List<Term> _detectTermsFromScriptByParsing() {
    List<Term> terms = [];
    for (var termHTMLA in termElements) {
      String termHTML = termHTMLA['h'];
      termHTML = termHTML.replaceFirst('th', 'a').substring(0, termHTML.length - 4) + 'a>';

      final termDoc = DocumentFragment.html(termHTML);
      final tooltip = termDoc.querySelector('a').attributes['tooltip'];

      if(tooltip != null)
      terms.add(Term(termDoc.text, tooltip));
    }
    return terms;
  }

  

}

class Term {
  String termCode;
  String termName;

  Term(this.termCode, this.termName);

  //For debugging only.
  @override
  String toString() {
    return termCode + ":" + termName;
  }
}

class GradeBox {
  String courseNumber;
  Term term;
  String grade;
  String studentID;

  GradeBox(this.courseNumber, this.term, this.grade, this.studentID);

  //For debugging only.
  @override
  String toString() {
    return "${this.term.toString()} for ${this.grade} for course # ${this.courseNumber} for student ${this.studentID}";
  }
}