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

class GradeboxGridBox{
  bool clickable = false;
}

class TeacherIDBox extends GradeboxGridBox{
  String teacherName;
  String timePeriod;
  String courseName;

  TeacherIDBox(this.teacherName, this.courseName, this.timePeriod);

  @override
  String toString() {
    return teacherName + ":" + courseName + ":" + timePeriod;
  }
}

class LessInfoBox extends GradeboxGridBox{
  Term term;
  String behavior;

  LessInfoBox(this.term, this.behavior);

  @override
  String toString() {
    return term.toString() + ":" + behavior;
  }
}

class GradeBox extends GradeboxGridBox{
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