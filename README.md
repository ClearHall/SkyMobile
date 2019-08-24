# SkyMobile

Cross platform SkyMobile with API.

## Getting Started with Documentation

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
    List grades = await skywardAPI.getGradeBookGrades(gradingTerms);
```

This function returns a list of GradeBox. It takes in ONE parameter from the function getGradeBookTerms() or custom terms. Note: This function **IS ASYNC** and will take a little more time to run. **CALL AWAIT** so your program will wait for this line of code to finish.

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
