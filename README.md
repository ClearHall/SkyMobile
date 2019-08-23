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
