import 'package:flutter/material.dart';
import 'SkywardScraperAPI/SkywardAPICore.dart';
import 'package:skymobile/SkywardNavViews/termGradeViewer.dart';
import 'customDialogOptions.dart';
import 'globalVariables.dart';
import 'package:skymobile/SkywardNavViews/assignmentInfoViewer.dart';
import 'package:skymobile/SkywardNavViews/assignmentsViewer.dart';
import 'SkywardScraperAPI/SkywardDistrictSearcher.dart';
import 'SkywardScraperAPI/SkywardAPITypes.dart';
import 'package:skymobile/辅助/accountTypes.dart';
import 'package:skymobile/辅助/jsonSaver.dart';
import 'package:skymobile/另/gpaCalculatorSchoolYear.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyMobile',
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => MyHomePage(),
        "/termviewer": (context) => TermViewerPage(),
        "/assignmentsviewer": (context) => AssignmentsViewer(),
        "/assignmentsinfoviewer": (context) => AssignmentInfoViewer(),
        "/gpacalculatorschoolyear": (context) => GPACalculatorSchoolYear()
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

  void initState() {
    super.initState();
    _getAccounts();
  }

  void _getGradeTerms(String user, String pass, BuildContext context) async {
    bool isCancelled = false;
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled = true;
    }, title: 'Loading', description: ('Getting your grades..'));

    showDialog(context: context, builder: (BuildContext context) => dialog)
        .then((val) {
      isCancelled = true;
    });

    skywardAPI = SkywardAPICore(district.districtLink);
    if (await skywardAPI.getSkywardAuthenticationCodes(user, pass) ==
        SkywardAPICodes.LoginFailed) {
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
      terms = await skywardAPI.getGradeBookTerms();
      gradeBoxes = (await skywardAPI.getGradeBookGrades(terms));
      if (!isCancelled) {
        Navigator.of(context, rootNavigator: true).popUntil((result) {
          return result.settings.name == '/';
        });
        Navigator.pushNamed(context, '/termviewer');
      }
    }
  }

  bool _isCredentialsSavedAlready(String user) {
    for (Account acc in accounts) {
      if (acc.district == district && acc.user == user) return true;
    }
    return false;
  }

  void _getGradeTermsFromAccount(Account acc, BuildContext context) async {
    bool isCancelled = false;
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled = true;
    }, title: 'Loading', description: ('Getting your grades..'));

    showDialog(context: context, builder: (BuildContext context) => dialog)
        .then((val) {
      isCancelled = true;
    });
    ;

    skywardAPI = SkywardAPICore(district.districtLink);
    if (await skywardAPI.getSkywardAuthenticationCodes(acc.user, acc.pass) ==
        SkywardAPICodes.LoginFailed) {
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
      terms = await skywardAPI.getGradeBookTerms();
      gradeBoxes = (await skywardAPI.getGradeBookGrades(terms));
      if (!isCancelled) {
        Navigator.of(context, rootNavigator: true).popUntil((result) {
          return result.settings.name == '/';
        });
        Navigator.pushNamed(context, '/termviewer');
      }
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
        }));
  }

  TextEditingController _controllerUsername = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  bool isInAccountChooserStatus = false;
  List<Account> accounts = [];

  //NOTE: USING THIS IS VERY BUGGY!!!!!
//  void _debugUseGenerateFakeAccounts(int numOfFakeAccounts) {
//    accounts = [];
//    for (int i = 0; i < numOfFakeAccounts; i++) {
//      accounts.add(Account(i.toString(), i.toString(), i.toString(), null));
//    }
//  }

  void _getAccounts() async {
    if (await jsonSaver.accountFileExists()) {
      List unconverted = (await jsonSaver.readListData());
      accounts = List<Account>.from(unconverted);
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
                  splashColor: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(16),
                  onTap:
                      !(accounts.length > 0 && accounts.first.district == null)
                          ? () => {
                                focus.unfocus(),
                                district = acc.district,
                                _getGradeTermsFromAccount(acc, context)
                              }
                          : () => {},
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: Colors.blueAccent, width: 2)),
                    child: accounts.length > 0 &&
                            accounts.first.district == null
                        ? ListTile(
                            title: Text(
                            acc.nick,
                            style: new TextStyle(
                                fontSize: 20.0, color: Colors.blueAccent),
                          ))
                        : ListTile(
                            title: Text(
                              acc.nick,
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.blueAccent),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(
                                      Icons.delete_forever,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
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
                                                  btnTextForConfirmation: 'Yes',
                                                  btnTextForCancel: 'No'));
                                    }),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  color: Colors.white,
                                  onPressed: () {
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
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2)),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20, bottom: 10),
        ),
        Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: Colors.white10,
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
                        child: ListView(shrinkWrap: true, children: widget)),
                Container(
                    padding: EdgeInsets.only(
                        top: 0, left: 30, right: 30, bottom: 25),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                          splashColor: Colors.orangeAccent,
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
                                    color: Colors.orangeAccent, width: 2)),
                            child: new Text(
                              'Credential Login',
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.orangeAccent),
                            ),
                          )),
                    )),
              ],
            ))
      ]);
    } else {
      listView = ListView(shrinkWrap: true, children: <Widget>[
        Container(
          child: Text('Login',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2)),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20, bottom: 10),
        ),
        Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: Colors.white10,
            child: ListView(shrinkWrap: true, children: <Widget>[
              Container(
                  padding:
                      EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 0),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: new Text(
                      'Enter your Skyward Credentials for ${district.districtName}.',
                      style: new TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  )),
              Container(
                  padding:
                      EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 15),
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    autofocus: false,
                    controller: _controllerUsername,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(18),
                        labelText: "Username",
                        labelStyle: TextStyle(color: Colors.blue),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(16))),
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                  )),
              Container(
                  padding:
                      EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 10),
                  child: TextFormField(
                    focusNode: focus,
                    controller: _controllerPassword,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(18),
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.blue),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(16))),
                    onFieldSubmitted: (v) {
                      //if(!focus.hasPrimaryFocus){
                      focus.unfocus();
                      // }
                    },
                  )),
              new Container(
                  padding:
                      EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        splashColor: Colors.orangeAccent,
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
                                  color: Colors.orangeAccent, width: 2)),
                          child: new Text(
                            'Submit',
                            style: new TextStyle(
                                fontSize: 20.0, color: Colors.orangeAccent),
                          ),
                        )),
                  )),
              new Container(
                  padding:
                      EdgeInsets.only(top: 0, left: 30, right: 30, bottom: 20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        splashColor: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => {_showDialog()},
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                  color: Colors.orangeAccent, width: 2)),
                          child: new Text(
                            'Search District',
                            style: new TextStyle(
                                fontSize: 20.0, color: Colors.orangeAccent),
                          ),
                        )),
                  )),
              new Container(
                  padding:
                      EdgeInsets.only(top: 0, left: 30, right: 30, bottom: 25),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        splashColor: Colors.orangeAccent,
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
                                  color: Colors.orangeAccent, width: 2)),
                          child: new Text(
                            'Choose Accounts',
                            style: new TextStyle(
                                fontSize: 20.0, color: Colors.orangeAccent),
                          ),
                        )),
                  )),
            ]))
      ]);
    }

    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: listView)));
  }
}
