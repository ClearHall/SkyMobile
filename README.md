# SkyMobile

Cross platform SkyMobile with API.

# Changelog

Changelog for SKYSCRAPEAPI and SkyMobile.

## SKYSCRAPEAPI

### V1.2.1

- Fixed bug where assignments with the same name would display the same details: *THIS BUG AFFECTS SKYMOBILE iOS AND WILL NOT BE FIXED FOR SKYMOBILE iOS*

### V1.2

- Can scrape assignment details.

### V1

- Build the basic foundation. Initial release.
- Can scrape gradebook and assignments.

## SkyMobile

### V1.0.0

- Initial Release
- Can check grades, assignments, assignment details
- Uses SKYSCRAPEAPI V1.2

## Documentation

**DOCUMENTATION VERSION 1.2.1**

To use this API, you must take the package SkywardScraperAPI. I have not made this implementable with pubspec.yaml.

```
var skywardBaseURL = 'https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/';
var skywardAPI = SkywardAPICore(skywardBaseURL);
await skywardAPI.getSkywardAuthenticationCodes({username}, {password});
```

The code above demonstrates the creation of a SkywardAPI instance and initializing it. The URL provided by the developer must be the base URL of the district's skyward website without 'seplog01.w'.

You will also have to import 2 dart files:
```
import 'SkywardScraperAPI/SkywardAPICore.dart';
import 'SkywardScraperAPI/SkywardAPITypes.dart';
```

## Functions to Know

Some important functions to know that'll help you use the API.

### Getting the available grading terms 

```
List<Term> gradingTerms = await skywardAPI.getGradeBookTerms();
```

This function returns a list of terms and allows you to get the abbreviated and full name of terms. Note: This function **IS ASYNC** and will take a little more time to run. **CALL AWAIT** so your program will wait for this line of code to finish.

### Getting the available gradebook grades 

```
List<GradeboxGridBox> grades = await skywardAPI.getGradeBookGrades(gradingTerms);
```

This function returns a list of GradeBox. It takes in ONE parameter from the function getGradeBookTerms() or custom terms. Note: This function **IS ASYNC** and will take a little more time to run. **CALL AWAIT** so your program will wait for this line of code to finish.

### Getting the assignments in a term and course

```
List<AssignmentsGridBox> assignmentBoxes = await skywardAPI.getAssignmentsFromGradeBox(gradeboxGridBox);
```

This function returns a list of AssignmentsGridBox. It takes in ONE parameter from the function getGradeBookGrades() or custom grade boxes *not recommended*. Note: This function **IS ASYNC** and will take a little more time to run. **CALL AWAIT** so your program will wait for this line of code to finish.

### Getting assignment details from assignment

```
List<AssignmentInfoBox> assignmentInfoBoxes = await skywardAPI.getAssignmentInfoFromAssignment(assignmentBox);
```

This function returns a list of AssignmentInfoBox. It takes in ONE parameter from the function getAssignmentsFromGradeBox() or custom assignment boxes *not recommended*. Note: This function **IS ASYNC** and will take a little more time to run. **CALL AWAIT** so your program will wait for this line of code to finish.

## Types

The following types are the only types you will need to know about.

#### Term
- String termCode: The term code such as PR1.
- String termName: The term name such as TERM 1.

#### GradeboxGridBox
- bool clickable: If the box is clickable and has another dialog. **NOTE: Default value is false**

#### TeacherIDBox

Inherits GradeboxGridBox.

- String teacherName: The teacher name such as BOB PHILLIPS.
- String timePeriod: The period time and period number such as Period1(7:30-8:30AM).
- String courseName: The course name such as Biology AP.

#### LessInfoBox

Inherits GradeboxGridBox.

- Term term: The term type that contains code and name.
- String behavior: The extra text associated such as E.


#### GradeBox

Inherits GradeboxGridBox.

- String courseNumber: Course ID used to identify the course.
- Term term: Term used to identify the term.
- String grade: Your grade for that Term such as 75.
- String studentID: **NOT YOUR USERNAME** Your student ID to identify your session such as 33198.

#### AssignmentsGridBox

Inherits GradeboxGridBox.

- String grade: Your grade such as 95.
- String decimalGrade: Your grade down to the decimal such as 94.5.
- String gradeOutOfMax: Your grade out of the maximum points such as 94.5 out of 100. (* out of 100) if no grade.

#### Assignment

Inherits AssignmentsGridBox.

- String studentID: **NOT YOUR USERNAME** Your student ID to identify your session such as 33198.
- String assignmentID: Assignment ID used to get more assignment details.
- String assignmentName: The assignment name.
- String dateDue: Due date of the assignment.

#### CategoryHeader

Inherits AssignmentsGridBox.

- String catName: Category name such as DAILY.
- String weight: Weight of category such as 50.00%.

#### AssignmentInfoBox

- String infoName: Assignment key such as Median:
- String info: Assignment key value such as 85.32

- String getUIMessage(): Returns infoName and info together to fit into UI such as "Median: 85.32"
