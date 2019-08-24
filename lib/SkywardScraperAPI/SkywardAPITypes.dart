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

class GridBox{
  bool clickable = false;
}

class TeacherIDBox extends GridBox{
  String teacherName;
  String timePeriod;
  String courseName;

  TeacherIDBox(this.teacherName, this.courseName, this.timePeriod);

  @override
  String toString() {
    return teacherName + ":" + courseName + ":" + timePeriod;
  }
}

class LessInfoBox extends GridBox{
  Term term;
  String behavior;

  LessInfoBox(this.term, this.behavior);

  @override
  String toString() {
    return term.toString() + ":" + behavior;
  }
}

class GradeBox extends GridBox{
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

class AssignmentsGridBox extends GridBox{
  String grade;
  String decimalGrade;
  String gradeOutOfMax;

  AssignmentsGridBox(this.grade, this.decimalGrade, this.gradeOutOfMax);

  @override
  String toString() {
    return 'AssignmentsGridBox{grade: $grade, decimalGrade: $decimalGrade, gradeOutOfMax: $gradeOutOfMax';
  }

}

class Assignment extends AssignmentsGridBox{
  String studentID;
  String assignmentID;
  String assignmentName;
  String dateDue;

  Assignment(this.studentID, this.assignmentID, this.dateDue, this.assignmentName, String grade, String gradeOutOfMax, String decimalGrade):super(grade, decimalGrade, gradeOutOfMax);

  @override
  String toString() {
    return 'Assignment{studentID: $studentID, assignmentID: $assignmentID, assignmentName: $assignmentName, grade: $grade, decimalGrade: $decimalGrade, gradeOutOfMax: $gradeOutOfMax, dateDue: $dateDue}';
  }
}

class CategoryHeader extends AssignmentsGridBox{
  String catName;
  String weight;

  CategoryHeader(this.catName, this.weight, String grade, String gradeOutOfMax, String decimalGrade):super(grade, decimalGrade, gradeOutOfMax);

  @override
  String toString() {
    return 'CategoryHeader{catName: $catName,weight: $weight grade: $grade, decimalGrade: $decimalGrade, gradeOutOfMax: $gradeOutOfMax}';
  }
}