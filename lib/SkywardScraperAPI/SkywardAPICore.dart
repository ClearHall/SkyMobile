/*
  SKYSCRAPEAPI
  In-Code documentation will be written for those who would like to modify the API for their own purposes.
 */

import 'SkywardAuthenticator.dart';
import 'GradebookAccessor.dart';
import 'AssignmentAccessor.dart';
import 'SkywardAPITypes.dart';
import 'AssignmentInfoAccessor.dart';
import 'HistoryAccessor.dart';

class SkywardAPICore {
  Map<String, String> loginSessionRequiredBodyElements;
  String _baseURL;
  String _gradebookHTML;
  GradebookAccessor gradebookAccessor = GradebookAccessor();
  String user, pass;

  SkywardAPICore(this._baseURL) {
    if (_verifyBaseURL(this._baseURL)) {
      this._baseURL =
          this._baseURL.substring(0, this._baseURL.lastIndexOf('/') + 1);
    }
    if (_baseURL.contains("wsEAplus"))
      _baseURL = _baseURL.substring(
              0, _baseURL.indexOf('wsEAplus') + 'wsEAplus'.length) +
          "/";
  }

  bool _verifyBaseURL(String url) {
    return !url.endsWith('/');
  }

  //Returns true for success and false for failed.
  getSkywardAuthenticationCodes(String u, String p) async {
    user = u;
    pass = p;
    var loginSessionMap =
        await SkywardAuthenticator.getNewSessionCodes(user, pass, _baseURL);
    if (loginSessionMap == null) {
      return SkywardAPIErrorCodes.LoginFailed;
    } else {
      loginSessionRequiredBodyElements = loginSessionMap;
    }
  }

  _initGradebook({int timeRan = 0}) async {
    if (timeRan > 10) return SkywardAPIErrorCodes.CouldNotRefresh;
    if (_gradebookHTML == null) {
      var result = await gradebookAccessor.getGradebookHTML(
          loginSessionRequiredBodyElements, _baseURL);
      if (result == SkywardAPIErrorCodes.LoginSessionExpired) {
        getSkywardAuthenticationCodes(user, pass);
        _initGradebook(timeRan: timeRan + 1);
      }
    }
  }

  getGradeBookTerms() async {
    var result = await _initGradebook();
    if (result == SkywardAPIErrorCodes.CouldNotRefresh)
      return SkywardAPIErrorCodes.CouldNotRefresh;
    return gradebookAccessor.getTermsFromDocCode();
  }

  getGradeBookGrades(List<Term> terms) async {
    try {
      var result = await _initGradebook();
      if (result == SkywardAPIErrorCodes.CouldNotRefresh)
        return SkywardAPIErrorCodes.CouldNotRefresh;
      return gradebookAccessor.getGradeBoxesFromDocCode(_gradebookHTML, terms);
    } catch (e) {
      return SkywardAPIErrorCodes.CouldNotScrapeGradeBook;
    }
  }

  getAssignmentsFromGradeBox(GradeBox gradeBox, {int timesRan = 0}) async {
    if(timesRan > 10) return SkywardAPIErrorCodes.AssignmentScrapeFailed;
    Map<String, String> assignmentsPostCodes =
        Map.from(loginSessionRequiredBodyElements);
    var html = await AssignmentAccessor.getAssignmentsHTML(
        assignmentsPostCodes,
        _baseURL,
        gradeBox.courseNumber,
        gradeBox.term.termName);
    if(html == SkywardAPIErrorCodes.AssignmentScrapeFailed){
      getSkywardAuthenticationCodes(user, pass);
      getAssignmentsFromGradeBox(gradeBox, timesRan: timesRan + 1);
    }else{
      try {
        return AssignmentAccessor.getAssignmentsDialog(html);
      }catch(e){
        return SkywardAPIErrorCodes.AssignmentParseFailed;
      }
    }
  }

  getAssignmentInfoFromAssignment(Assignment assignment, {int timesRan = 0}) async {
    Map<String, String> assignmentsPostCodes =
        Map.from(loginSessionRequiredBodyElements);
    var html = await AssignmentInfoAccessor.getAssignmentsDialogHTML(
        assignmentsPostCodes, _baseURL, assignment);
    if(html == SkywardAPIErrorCodes.AssignmentScrapeFailed){
      getSkywardAuthenticationCodes(user, pass);
      getAssignmentInfoFromAssignment(assignment, timesRan: timesRan + 1);
    }
    return AssignmentInfoAccessor.getAssignmentInfoBoxesFromHTML();
  }

  getHistory() async {
    return (await HistoryAccessor.parseGradebookHTML(
        await HistoryAccessor.getGradebookHTML(
            loginSessionRequiredBodyElements, _baseURL)));
  }
}

enum SkywardAPIErrorCodes {
  Succeeded, //Placeholder
  LoginFailed,
  LoginSessionExpired,
  CouldNotScrapeGradeBook,
  CouldNotRefresh,
  AssignmentScrapeFailed,
  AssignmentParseFailed,
  AssignmentInfoScrapeFailed,
  AssignmentInfoParseFailed
}
