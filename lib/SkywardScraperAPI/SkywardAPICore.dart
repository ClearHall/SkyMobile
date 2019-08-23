import 'SkywardAuthenticator.dart';
import 'GradebookAccessor.dart';
import 'AssignmentAccessor.dart';
import 'SkywardAPITypes.dart';

class SkywardAPICore {
  Map<String, String> loginSessionRequiredBodyElements;
  final String _baseURL;
  String _gradebookHTML;
  GradebookAccessor gradebookAccessor = GradebookAccessor();

  SkywardAPICore(this._baseURL) {
    if (_verifyBaseURL(this._baseURL)) {
      this._baseURL.substring(0, this._baseURL.lastIndexOf('/') + 1);
    }
  }

  bool _verifyBaseURL(String url) {
    return url.endsWith('/');
  }

  //Returns true for success and false for failed.
  getSkywardAuthenticationCodes(String user, String pass) async {
    var loginSessionMap =
        await SkywardAuthenticator.getNewSessionCodes(user, pass, _baseURL);
    if (loginSessionMap == null) {
      return SkywardAPICodes.LoginFailed;
    } else {
      loginSessionRequiredBodyElements = loginSessionMap;
      return SkywardAPICodes.LoginCodesReceived;
    }
  }

  _initGradebook() async{
    if(_gradebookHTML == null) {
      _gradebookHTML = await gradebookAccessor.getGradebookHTML(
          loginSessionRequiredBodyElements, _baseURL);
    }
  }

  getGradeBookTerms() async{
    await _initGradebook();
    return gradebookAccessor.getTermsFromDocCode();
  }

  getGradeBookGrades(List<Term> terms) async{
    await _initGradebook();
    return gradebookAccessor.getGradeBoxesFromDocCode(_gradebookHTML, terms);
  }

  getAssignmentsFromCourseAndTerm(GradeBox gradeBox) async{
    Map<String, String> assignmentsPostCodes = Map.from(loginSessionRequiredBodyElements);
    assignmentsPostCodes['action'] = 'viewGradeInfoDialog';
    assignmentsPostCodes['fromHttp'] = 'yes';
    assignmentsPostCodes['ishttp'] = 'true';
    assignmentsPostCodes['corNumId'] = gradeBox.courseNumber;
    assignmentsPostCodes['bucket'] = gradeBox.term.termName;

    print(assignmentsPostCodes);

    return await AssignmentAccessor.getAssignmentsHTML(assignmentsPostCodes, _baseURL);
  }

}

enum SkywardAPICodes { LoginFailed, LoginCodesReceived, CouldNotScrapeGradeBook }
