import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

bool didSessionExpire(String doc){
  Document docs = parse(doc);
  List<Element> elems = docs.getElementsByClassName('sfLogout');

  String literalToSearch = "Your session has expired and you have been logged out.<br />You may close this window.";

  for(Element elem in elems){
    for(Element script in elem.querySelectorAll('script')){
      if(script.text.contains(literalToSearch)){
        return true;
      }
    }
  }

  return false;
}