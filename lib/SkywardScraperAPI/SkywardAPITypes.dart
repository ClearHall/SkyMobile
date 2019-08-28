class Term {
  String termCode;
  String termName;

  Term(this.termCode, this.termName);

  //For debugging only.
  @override
  String toString() {
    return termCode + ":" + termName;
  }

  @override
  bool operator ==(other) {
    if(other is Term){
      return (other).termCode == this.termCode;
    }else{
      return false;
    }
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

class GradeTextBox extends GridBox{
  Term term;

  GradeTextBox(this.term);
}

class LessInfoBox extends GradeTextBox{
  String behavior;

  LessInfoBox(this.behavior, Term term):super(term);

  @override
  String toString() {
    return term.toString() + ":" + behavior;
  }
}

class GradeBox extends GradeTextBox{
  String courseNumber;
  String grade;
  String studentID;

  GradeBox(this.courseNumber, Term term, this.grade, this.studentID):super(term);

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
  String gbID;
  String assignmentName;
  String dateDue;

  Assignment(this.studentID, this.assignmentID,this.gbID, this.dateDue, this.assignmentName, String grade, String gradeOutOfMax, String decimalGrade):super(grade, decimalGrade, gradeOutOfMax);

  @override
  String toString() {
    return 'Assignment{studentID: $studentID, assignmentID: $assignmentID,gbID: $gbID, assignmentName: $assignmentName, grade: $grade, decimalGrade: $decimalGrade, gradeOutOfMax: $gradeOutOfMax, dateDue: $dateDue}';
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

class AssignmentInfoBox{
  String infoName;
  String info;

  String getUIMessage(){
    return infoName + ' ' + (info != null ? info : "");
  }

  AssignmentInfoBox(this.infoName, this.info);

  @override
  String toString() {
    return 'AssignmentInfoBox{infoName: $infoName, info: $info}';
  }
}

class SkywardSearchState{
  String stateName;
  String stateID;

  SkywardSearchState(this.stateName, this.stateID);

  @override
  String toString() {
    return 'State{stateName: $stateName, stateID: $stateID}';
  }
}

class SkywardDistrict{
  String districtName;
  String districtLink;

  SkywardDistrict(this.districtName, this.districtLink);

  @override
  String toString() {
    return 'SkywardDistrict{districtName: $districtName, districtLink: $districtLink}';
  }
}