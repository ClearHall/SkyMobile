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
    Map<String, String> gradingTerms = await skywardAPI.getGradeBookTerms();
```

This function returns a map of strings and allows you to get the abbreviated and full name of terms. Note: This function **IS ASYNC** and will take a little more time to run. **CALL AWAIT** so your program will wait for this line of code to finish.

### Getting the available gradebook grades 

```
    List grades = await skywardAPI.getGradeBookGrades();
```

This function returns a list of GradeBox. Note: This function **IS ASYNC** and will take a little more time to run. **CALL AWAIT** so your program will wait for this line of code to finish.

## Types to Know

Some types to know to help you better understand the API.

### Term

```
Term term = Term({Term Code ex. PR1}, {Term Name ex. TERM 1});
```

The term type allows you to store the correlating term name with term code. To get any of these attributes, just access their names:

```
print('Term Code: ${term.termCode}');
print('Term Name: ${term.termName}');
```

### GradeBox

```
GradeBox({Course ID}, {Term}, {Grade as a String}, {Student ID (Not neccesarily login username});
```

The GradeBox allows you to store many elements of a clickable term grade. Attributes include: courseNumber, term, grade, studentID.
