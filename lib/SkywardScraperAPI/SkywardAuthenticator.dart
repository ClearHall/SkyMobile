import 'package:http/http.dart' as http;

class SkywardAuthenticator{
  static getNewSessionCodes(String user, String pass, String baseURL) async{
    final String authenticationURL = baseURL + 'skyporthttp.w';
    var postResponse = await http.post(authenticationURL, body: {'codeType':'tryLogin', 'login':user, 'password':pass, 'requestAction':'eel'});
    var parsedMap = parsePostResponse(postResponse.body);
    return parsedMap;
  }

  static Map<String, String> parsePostResponse(String postResponse){
    String dissectedString = postResponse.substring(4, postResponse.length - 5);
    if(dissectedString.contains('Invalid login or password.')){
      return null;
    }else{
      var toks = dissectedString.split('^');
      return Map.fromIterables(['dwd', 'wfaacl', 'encses'], [toks[0], toks[3], toks[14]]);
    }
  }
}