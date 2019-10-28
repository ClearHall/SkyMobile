import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:skymobile/Settings/themeColorManager.dart';
import 'package:skyscrapeapi/skyscrape.dart';
import 'package:skymobile/Navigation//termGradeViewer.dart';
import 'ExtraViewPackages/customDialogOptions.dart';
import 'HelperUtilities/globalVariables.dart';
import 'package:skymobile/Navigation/assignmentInfoViewer.dart';
import 'package:skymobile/Navigation/assignmentsViewer.dart';
import 'package:skyscrapeapi/district_searcher.dart';
import 'package:skyscrapeapi/data_types.dart';
import 'package:skymobile/HelperUtilities/accountTypes.dart';
import 'package:skymobile/HelperUtilities/jsonSaver.dart';
import 'package:skymobile/GPACalculator/schoolYear.dart';
import 'package:skymobile/GPACalculator/classes.dart';
import 'package:skymobile/GPACalculator/settings.dart';
import 'package:skymobile/Settings/settings_viewer.dart';

void main() async {
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.settings);
  var retrieved = await jsonSaver.readListData();
  if (retrieved is Map) {
    settings.addAll(retrieved);
    (settings['Theme']['option'] as Map).forEach((k, v) {
      if (v == true)
        runApp(MyApp(ThemeManager.colorNameToThemes.keys.toList()[
            ThemeManager.colorNameToThemes.values.toList().indexOf(k)]));
    });
  } else {
    settings['Theme']['option']
        [ThemeManager.colorNameToThemes[themeManager.currentTheme]] = true;
    runApp(MyApp(themeManager.currentTheme));
  }
}

class MyApp extends StatelessWidget {
  ColorTheme themeSelected;
  MyApp(this.themeSelected);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    themeManager.currentTheme = themeSelected;

    return MaterialApp(
      title: 'SkyMobile',
      theme: ThemeData(
        primarySwatch: themeManager.getColor(TypeOfWidget.text),
      ),
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => MyHomePage(),
        "/termviewer": (context) => TermViewerPage(),
        "/assignmentsviewer": (context) => AssignmentsViewer(),
        "/assignmentsinfoviewer": (context) => AssignmentInfoViewer(),
        "/gpacalculatorschoolyear": (context) => GPACalculatorSchoolYear(),
        "/gpacalculatorclasses": (context) =>
            GPACalculatorClasses(ModalRoute.of(context).settings.arguments),
        "/gpacalculatorsettings": (context) => GPACalculatorSettings(),
        "/settings": (context) => SettingsViewer()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.accounts);
  static SkywardDistrict district = SkywardDistrict('FORT BEND ISD',
      'https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w');
  final _auth = LocalAuthentication();

  void initState() {
    super.initState();
    _getPreviouslySavedDistrict();
    _getAccounts();
  }

  void _getPreviouslySavedDistrict() async {
    JSONSaver jsonSaver = JSONSaver(FilesAvailable.previousDistrict);
    var districta = await jsonSaver.readListData();

    if (districta is SkywardDistrict) district = districta;
  }

  void _saveDistrict() async {
    JSONSaver jsonSaver = JSONSaver(FilesAvailable.previousDistrict);
    await jsonSaver.saveListData(district);
  }

  void _getGradeTerms(String user, String pass, BuildContext context) async {
    List<bool> isCancelled = [false];
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled[0] = true;
    }, title: 'Loading', description: ('Getting your grades..'));

    showDialog(context: context, builder: (BuildContext context) => dialog)
        .then((val) {
      isCancelled[0] = true;
    });

    skywardAPI = SkywardAPICore(district.districtLink);
    try {
      if (!(await skywardAPI.getSkywardAuthenticationCodes(user, pass))) {
        Navigator.of(context).pop(dialog);
        showDialog(
            context: context,
            builder: (BuildContext) {
              return HuntyDialog(
                  title: 'Uh-Oh',
                  description:
                      'Invalid Credentials or Internet Failure. Please check your username and password and your internet connection.',
                  buttonText: 'Ok');
            });
      } else {
        _getAccounts();
        if (!_isCredentialsSavedAlready(user)) {
          await showDialog(
              context: context,
              builder: (BuildContext) {
                return HuntyDialogForConfirmation(
                  title: 'New Account',
                  description:
                      'New account detected, would you like to save this account?.',
                  runIfUserConfirms: () {
                    setState(() {
                      accounts.add(Account(user, user, pass, district));
                      jsonSaver.saveListData(accounts);
                    });
                  },
                  btnTextForCancel: "Cancel",
                  btnTextForConfirmation: 'Ok',
                );
              });
        }
        await getTermsAndGradeBook(
            isCancelled, dialog, Account(null, user, pass, district));
      }
    } catch (e) {
      Navigator.of(context).pop(dialog);
      _underMaintence(context);
    }
  }

  _underMaintence(BuildContext context) {
    showDialog(
        context: context,
        builder: (bc) {
          return HuntyDialog(
              title: 'Oh-No',
              description:
                  'An error occured. Your district\'s skyward is probably in maintenance.',
              buttonText: 'Ok');
        });
  }

  bool _isCredentialsSavedAlready(String user) {
    for (Account acc in accounts) {
      if (acc.district == district && acc.user == user) return true;
    }
    return false;
  }

  void _getGradeTermsFromAccount(Account acc) async {
    List<bool> isCancelled = [false];
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled[0] = true;
    }, title: 'Loading', description: ('Getting your grades..'));

    showDialog(context: context, builder: (context) => dialog).then((val) {
      isCancelled[0] = true;
    });

    skywardAPI = SkywardAPICore(district.districtLink);
    try {
      if (!(await skywardAPI.getSkywardAuthenticationCodes(
          acc.user, acc.pass))) {
        Navigator.of(context).pop(dialog);
        showDialog(
            context: context,
            builder: (BuildContext) {
              return HuntyDialogForConfirmation(
                title: 'Uh-Oh',
                description:
                    'Invalid Credentials or Internet Failure. Would you like to remove this account?.',
                runIfUserConfirms: () {
                  setState(() {
                    accounts.remove(acc);
                    jsonSaver.saveListData(accounts);
                  });
                },
                btnTextForCancel: "Cancel",
                btnTextForConfirmation: 'Ok',
              );
            });
      } else {
        await getTermsAndGradeBook(isCancelled, dialog, acc);
      }
    } catch (e) {
      Navigator.of(context).pop(dialog);
      _underMaintence(context);
    }
  }

  Future getTermsAndGradeBook(
      List<bool> isCancelled, HuntyDialogLoading dialog, Account acc) async {
    try {
      var termRes = await skywardAPI.getGradeBookTerms();
      var gradebookRes = (await skywardAPI.getGradeBookGrades(termRes));
      terms = termRes;
      gradeBoxes = gradebookRes;
    } catch (e) {
      isCancelled[0] = true;
      Navigator.of(context).pop(dialog);
      await showDialog(
          context: context,
          builder: (BuildContext) {
            return HuntyDialog(
                title: 'Oh No!',
                description:
                    'An error occured and we could not get your grades. Please report this to a developer! An error occured while parsing your grades.',
                buttonText: 'Ok');
          });
    }
    if (!(isCancelled.first)) {
      currentSessionIdentifier = acc.user;
      Navigator.of(context, rootNavigator: true).popUntil((result) {
        return result.settings.name == '/';
      });
      Navigator.pushNamed(context, '/termviewer');
    }
  }

  _showDialog() async {
    await SkywardDistrictSearcher.getStatesAndPostRequiredBodyElements();
    showDialog(
            context: context,
            builder: ((BuildContext context) {
              return HuntyDistrictSearcherWidget(
                  title: 'District Searcher',
                  description:
                      "Select your state and enter your district's name. (Ex: Fort Bend ISD)",
                  buttonText: 'OK');
            }))
        .then((val) {
      setState(() {});
    }).then((val) {
      _saveDistrict();
    });
  }

  TextEditingController _controllerUsername = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  bool isInAccountChooserStatus = false;
  List<Account> accounts = [];

  //NOTE: USING THIS IS VERY BUGGY!!!!!
  void _debugUseGenerateFakeAccounts(int numOfFakeAccounts) {
    accounts = [];
    for (int i = 0; i < numOfFakeAccounts; i++) {
      accounts.add(Account(i.toString(), i.toString(), i.toString(),
          SkywardDistrict('lol', 'ddd')));
    }
  }

  void _getAccounts() async {
    if (await jsonSaver.doesFileExist()) {
      var unconverted = (await jsonSaver.readListData());
      if (unconverted is List) accounts = List<Account>.from(unconverted);
    } else {
      await jsonSaver.saveListData([]);
    }
    if (accounts.length == 0) {
      accounts.add(Account('You have no saved accounts', null, null, null));
    }
  }

  void _removeDebugAccounts() {
    for (int i = accounts.length - 1; i >= 0; i--) {
      if (accounts[i].district == null) {
        accounts.removeAt(i);
      }
    }
    jsonSaver.saveListData(accounts);
  }

  _shouldAuthenticateAndContinue(Account acc, Function(Account) action) async {
    if (settings['Biometric Authentication']['option']) {
      try {
        bool _isAuthenticated = await _auth.authenticateWithBiometrics(
            localizedReason: 'Authenticate to view grades',
            useErrorDialogs: false,
            stickyAuth: true);
        if (_isAuthenticated) {
          district = acc.district;
          action(acc);
        }
      } catch (e) {
        if (e is PlatformException) {
          if (e.code == 'LockedOut') {
            await showDialog(
                context: context,
                builder: (bc) => HuntyDialog(
                    title: 'Authentication Error',
                    description: e.message,
                    buttonText: 'Ok'));
          } else {
            await showDialog(
                context: context,
                builder: (bc) => HuntyDialog(
                    title: 'Authentication Error',
                    description: e.message +
                        '\nSkyMobile will disable authentication for you.',
                    buttonText: 'Ok'));
            settings['Biometric Authentication']['option'] = false;
            _shouldAuthenticateAndContinue(acc, action);
          }
        }
      }
    } else {
      district = acc.district;
      action(acc);
    }
  }

  final focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    if (district == null) {
      district = SkywardDistrict('FORT BEND ISD',
          'https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w');
    }
    if (accounts.length == 0) {
      accounts.add(Account('You have no saved accounts', null, null, null));
    }
    if (accounts.length > 1) {
      _removeDebugAccounts();
    }
    ListView listView;

    if (isInAccountChooserStatus) {
      List<Widget> widget = [];

      for (Account acc in accounts) {
        widget.add(Container(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                  splashColor: themeManager.getColor(TypeOfWidget.button),
                  borderRadius: BorderRadius.circular(16),
                  onTap:
                      !(accounts.length > 0 && accounts.first.district == null)
                          ? () {
                              focus.unfocus();
                              _shouldAuthenticateAndContinue(
                                  acc, _getGradeTermsFromAccount);
                            }
                          : () => {},
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                            color: themeManager.getColor(TypeOfWidget.text),
                            width: 2)),
                    child: accounts.length > 0 &&
                            accounts.first.district == null
                        ? ListTile(
                            title: Text(
                            acc.nick,
                            style: new TextStyle(
                                fontSize: 20.0,
                                color:
                                    themeManager.getColor(TypeOfWidget.text)),
                          ))
                        : ListTile(
                            title: Text(
                              acc.nick,
                              style: new TextStyle(
                                  fontSize: 20.0,
                                  color:
                                      themeManager.getColor(TypeOfWidget.text)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(
                                      Icons.delete_forever,
                                      color: themeManager.getColor(null),
                                    ),
                                    onPressed: () {
                                      _shouldAuthenticateAndContinue(acc,
                                          (acc) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                HuntyDialogForConfirmation(
                                                    title: 'Account Deletion',
                                                    description:
                                                        'Are you sure you want to remove this account from your device?',
                                                    runIfUserConfirms: () {
                                                      setState(() {
                                                        accounts.remove(acc);
                                                        jsonSaver.saveListData(
                                                            accounts);
                                                      });
                                                    },
                                                    btnTextForConfirmation:
                                                        'Yes',
                                                    btnTextForCancel: 'No'));
                                      });
                                    }),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  color: themeManager.getColor(null),
                                  onPressed: () {
                                    _shouldAuthenticateAndContinue(acc, (acc) {
                                      TextEditingController accountEditor =
                                          TextEditingController();
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              HuntyDialogWithText(
                                                  hint: 'Edit Account',
                                                  textController: accountEditor,
                                                  okPressed: () {
                                                    setState(() {
                                                      acc.nick =
                                                          accountEditor.text;
                                                      jsonSaver.saveListData(
                                                          accounts);
                                                    });
                                                  },
                                                  title: 'Edit Account Name',
                                                  description:
                                                      'Type in a new account name to be displayed. This does not affect logging in and logging out.',
                                                  buttonText: 'Submit'));
                                    });
                                  },
                                )
                              ],
                            )),
                  )),
            )));
      }
      widget.add(SizedBox(
        height: 24,
      ));
      listView = ListView(shrinkWrap: true, children: <Widget>[
        Container(
          child: Text('Accounts',
              style: TextStyle(
                  color: themeManager.getColor(null),
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2)),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20, bottom: 10),
        ),
        Container(
            decoration: new BoxDecoration(boxShadow: [
              new BoxShadow(
                color: Colors.black,
                blurRadius: 20.0,
              ),
            ]),
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: themeManager.getColor(TypeOfWidget.subBackground),
                child: Column(
                  children: <Widget>[
                    widget.length > 5
                        ? Container(
                            padding: EdgeInsets.only(bottom: 20, top: 20),
                            child: ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 500),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: widget,
                                  ),
                                )))
                        : Container(
                            padding: EdgeInsets.only(bottom: 20, top: 20),
                            child:
                                ListView(shrinkWrap: true, children: widget)),
                    Container(
                        padding: EdgeInsets.only(
                            top: 0, left: 30, right: 30, bottom: 25),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                              splashColor:
                                  themeManager.getColor(TypeOfWidget.text),
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => {
                                    setState(() {
                                      isInAccountChooserStatus =
                                          !isInAccountChooserStatus;
                                    })
                                  },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                        color: themeManager
                                            .getColor(TypeOfWidget.button),
                                        width: 2)),
                                child: new Text(
                                  'Credential Login',
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      color: themeManager
                                          .getColor(TypeOfWidget.button)),
                                ),
                              )),
                        )),
                  ],
                )))
      ]);
    } else {
      listView = ListView(shrinkWrap: true, children: <Widget>[
        Container(
          child: Text('Login',
              style: TextStyle(
                  color: themeManager.getColor(null),
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2)),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20, bottom: 10),
        ),
        Container(
            decoration: new BoxDecoration(boxShadow: [
              new BoxShadow(
                color: Colors.black,
                blurRadius: 20.0,
              ),
            ]),
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: themeManager.getColor(TypeOfWidget.subBackground),
                child: ListView(shrinkWrap: true, children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(
                          top: 20, left: 30, right: 30, bottom: 0),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        child: new Text(
                          'Enter your Skyward Credentials for ${district.districtName}.',
                          style: new TextStyle(
                              fontSize: 20.0,
                              color: themeManager.getColor(null)),
                        ),
                      )),
                  Container(
                      padding: EdgeInsets.only(
                          top: 20, left: 16, right: 16, bottom: 15),
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        autofocus: false,
                        controller: _controllerUsername,
                        style: TextStyle(color: themeManager.getColor(null)),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(18),
                            labelText: "Username",
                            labelStyle: TextStyle(
                                color:
                                    themeManager.getColor(TypeOfWidget.text)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: themeManager
                                        .getColor(TypeOfWidget.text),
                                    width: 2),
                                borderRadius: BorderRadius.circular(16)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: themeManager
                                        .getColor(TypeOfWidget.text),
                                    width: 2),
                                borderRadius: BorderRadius.circular(16))),
                        onFieldSubmitted: (v) {
                          FocusScope.of(context).requestFocus(focus);
                        },
                      )),
                  Container(
                      padding: EdgeInsets.only(
                          top: 0, left: 16, right: 16, bottom: 10),
                      child: TextFormField(
                        focusNode: focus,
                        controller: _controllerPassword,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: themeManager.getColor(null)),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(18),
                            labelText: "Password",
                            labelStyle: TextStyle(
                                color:
                                    themeManager.getColor(TypeOfWidget.text)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: themeManager
                                        .getColor(TypeOfWidget.text),
                                    width: 2),
                                borderRadius: BorderRadius.circular(16)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: themeManager
                                        .getColor(TypeOfWidget.text),
                                    width: 2),
                                borderRadius: BorderRadius.circular(16))),
                        onFieldSubmitted: (v) {
                          //if(!focus.hasPrimaryFocus){
                          focus.unfocus();
                          // }
                        },
                      )),
                  new Container(
                      padding: EdgeInsets.only(
                          top: 20, left: 30, right: 30, bottom: 20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                            splashColor:
                                themeManager.getColor(TypeOfWidget.button),
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => {
                                  focus.unfocus(),
                                  _getGradeTerms(_controllerUsername.text,
                                      _controllerPassword.text, context)
                                },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                      color: themeManager
                                          .getColor(TypeOfWidget.button),
                                      width: 2)),
                              child: new Text(
                                'Submit',
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: themeManager
                                        .getColor(TypeOfWidget.button)),
                              ),
                            )),
                      )),
                  new Container(
                      padding: EdgeInsets.only(
                          top: 0, left: 30, right: 30, bottom: 20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                            splashColor:
                                themeManager.getColor(TypeOfWidget.button),
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => {_showDialog()},
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                      color: themeManager
                                          .getColor(TypeOfWidget.button),
                                      width: 2)),
                              child: new Text(
                                'Search District',
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: themeManager
                                        .getColor(TypeOfWidget.button)),
                              ),
                            )),
                      )),
                  new Container(
                      padding: EdgeInsets.only(
                          top: 0, left: 30, right: 30, bottom: 25),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                            splashColor:
                                themeManager.getColor(TypeOfWidget.text),
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => {
                                  setState(() {
                                    isInAccountChooserStatus =
                                        !isInAccountChooserStatus;
                                  })
                                },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                      color: themeManager
                                          .getColor(TypeOfWidget.button),
                                      width: 2)),
                              child: new Text(
                                'Choose Accounts',
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: themeManager
                                        .getColor(TypeOfWidget.button)),
                              ),
                            )),
                      )),
                ])))
      ]);
    }

    return Scaffold(
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        body: Center(
            child: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: listView)));
  }
}
