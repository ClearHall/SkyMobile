# SkyMobile 2.0



## Getting Started with Documentation

To use this API, you must take the package SkywardScraperAPI. I have not made this implementable with pubspec.yaml.

```
    var skywardBaseURL = 'https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/';
    var skywardAPI = SkywardAPICore(skywardBaseURL);
    await skywardAPI.getSkywardAuthenticationCodes({username}, {password});
```

The code above demonstrates the creation of a SkywardAPI instance and initializing it. The URL provided by the developer must be the base URL of the district's skyward website without 'seplog01.w'.

