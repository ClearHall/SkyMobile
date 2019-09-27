# SkyMobile

Cross platform SkyMobile with API.

Join the SkyMobile discord server [here](https://discord.gg/Hqvann5).

# Changelog

Changelog for SKYSCRAPEAPI and SkyMobile.

## SKYSCRAPEAPI

Main scraping API for SkyMobile cross platform.

### V1.5.2

- Fixed bug where duplicate SchoolYears were returned.

### V1.5.1

- Modified History Scraper and Data Types to support json saving.

### V1.5.0

- Added History Scraper. Allows you to scrape from sfacademichistory001.w.

### V1.4.1

- Adressed major bug which prevented users from Highland Park ISD from logging in. This should fix logging in bugs for all districts with wsEAplus in their url link name.

### V1.4.0

- Remade Assignment scraping algorithm to support more districts.

### V1.3.0

- Adds DistrictSearcher to search for districts family access links.

### V1.2.1

- Fixed bug where assignments with the same name would display the same details: *THIS BUG AFFECTS SKYMOBILE iOS AND WILL NOT BE FIXED FOR SKYMOBILE iOS*

### V1.2.0

- Can scrape assignment details.

### V1.0.0

- Build the basic foundation. Initial release.
- Can scrape gradebook and assignments.

## SkyMobile

### V2.0 Release

- Updates JSON Saver to save GPA Calculator modifications
- Adds GPA Calculator
  - HUGE Upgrade from GPA Calculator iOS
  - Adds new window for modifying specific school years
  - Popup window for class credit and level modification **SUBJECT TO CHANGE**
  - Selectable semesters to add into the GPA Calculator
- Uses SKYSCRAPEAPI V1.5.1

### V1.1.0 Beta

- Adds DistrictSearcher
- Fixes bugs for other districts
- Fixes multiple registered taps bug
- Added account saving
- Uses SKYSCRAPEAPI V1.4.1

### V1.0.0 Beta

- Initial Release
- Can check grades, assignments, assignment details
- Uses SKYSCRAPEAPI V1.2

# Documentation Version 1.5.1

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

### Searching for districts

Extra import needed: SkywardScraperAPI/SkywardDistrictSearcher.dart

```
await SkywardDistrictSearcher.getStatesAndPostRequiredBodyElements();
List<SkywardDistrict> districts = await SkywardDistrictSearcher.searchForDistrictLinkFromState("180", "Alvin");
```

Searches for districts and returns the link found for those districts. This link is not fool-proof and may be wrong. Contact me at hunter.han@gmail.com if any errors in links are found.

### Getting grading history

```
var history = await skywardAPI.getHistory();
```

This function returns a list of SchoolYear taken from sfacademichistory. Refer to SchoolYear documentation to understand how the datatype SchoolYear functions. Note: This function **IS ASYNC** and will take a little more time to run. **CALL AWAIT** so your program will wait for this line of code to finish.

## Types

The following type are the types you need to know to operate the API.

#### Term
- String termCode: The term code such as PR1.
- String termName: The term name such as TERM 1.

**JSON ENCODING FORMAT**
```
{
  'termCode': termCode,
  'termName': termName
}
```

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

- Map<String, String> attributes: Extra attributes such as {Assignment: QUIZ, Grade: 43}
- String getAssignment(): Returns assumed second attribute assignment name such as QUIZ.
- String getDecimal(): Searches for a decimal in attributes, if one isn't found, then an integer is retrieved. If an integer isn't found, then null is returned.
- String getIntGrade(): Searches for an integer in attributes, if one is not found, then returns null.

#### Assignment

Inherits AssignmentsGridBox.

- String studentID: **NOT YOUR USERNAME** Your student ID to identify your session such as 33198.
- String assignmentID: Assignment ID used to get more assignment details.
- String gbID: The extra attribute used to post.
- String assignmentName: Assignment name such as QUIZ.

#### CategoryHeader

Inherits AssignmentsGridBox.

- String catName: Category name such as DAILY.
- String weight: Weight of category such as 50.00%.

#### AssignmentInfoBox

- String infoName: Assignment key such as Median:
- String info: Assignment key value such as 85.32

- String getUIMessage(): Returns infoName and info together to fit into UI such as "Median: 85.32"

#### SkywardSearchState

- String stateName: Name of the state such as Texas.
- String stateID: Name of the corresponding state ID for example, Texas' state ID is 180.

#### SkywardDistrict

- String districtName: The name of the district stored inside such as "FORT BEND ISD"
- String districtLink: The link scraped from the district searcher such as "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w"

**JSON ENCODING FORMAT**
```
{
  'districtName': districtName,
  'districtLink': districtLink
}
```

#### SchoolYear

- String description: Name of the school year such as "2018-2019 9th grade"
- List<Term> terms: Terms from this school year such as [Term("CP1", "Citizenship 1"),Term("PR1", "Term 1")]
- List<Class> classes: Classes from this school year such as [Class("Biology", ["91"], 1.0, 3.0, ClassLevel.PreAP)]
- bool isEnabled = true: If the SchoolYear is enabled and counts toward the final GPA. Default value is true.
  
**JSON ENCODING FORMAT**
```
{
  'description': description,
  'terms': {
    {
      *Insert Term JSON Code*
    }, ...more terms(terms is a list)
  },
  'classes' : {
     {
      *Insert Class JSON Code*
     }, ...more classes
   },
   'isEnabled' : isEnabled
}
```

#### Class
- String name: Name of the class such as Precal PreAP
- List<String> grades: List of grades respective to the parent SchoolYear terms
- double credits: How many credits the class is worth such as 1.0
- double fourScaleCredits: How many credits the class is worth counting toward 4.0 scale
- ClassLevel classLevel: The level of the class
  
**JSON ENCODING FORMAT**
```
{
  'name': name,
  'grades': {
    {
     "grade",
     "grade",...more grades
    },
  },
  'credits' : credits,
  'fourScaleCredits' : fourScaleCredits,
   'classLevel' : classLevel
}
```

#### ClassLevel enum
- Regular
- PreAP
- AP
