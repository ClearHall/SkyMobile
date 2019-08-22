import 'package:http/http.dart' as http;

class AssignmentAccessor{

  static getAssignmentsHTML(Map<String, String> codes, String baseURL) async {
    final String gradebookURL = baseURL + 'sfgradebook001.w';

    var response = await http.post(gradebookURL, body: codes);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response.body;
  }



}