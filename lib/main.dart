import 'dart:io';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:local_auth/local_auth.dart';
import 'package:skymobile/ExtraViewPackages/credits.dart';
import 'package:skymobile/SupportWidgets/biometric_blur_view.dart';
import 'package:skymobile/SupportWidgets/custom_overscroll_behavior.dart';
import 'package:skymobile/HelperUtilities/manage_sky_vars.dart';
import 'package:skymobile/Navigation/messages.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skyscrapeapi/sky_core.dart';
import 'package:skymobile/Navigation//gradebook.dart';
import 'ExtraViewPackages/hunty_dialogs.dart';
import 'HelperUtilities/global.dart';
import 'package:skymobile/Navigation/assignment_info.dart';
import 'package:skymobile/Navigation/assignments.dart';
import 'package:skyscrapeapi/district_searcher.dart';
import 'package:skyscrapeapi/data_types.dart';
import 'package:skymobile/HelperUtilities/account_types.dart';
import 'package:skymobile/HelperUtilities/json_saver.dart';
import 'package:skymobile/GPACalculator/school_year.dart';
import 'package:skymobile/GPACalculator/classes.dart';
import 'package:skymobile/GPACalculator/settings.dart';
import 'package:skymobile/Settings/settings_viewer.dart';
import 'package:skymobile/ExtraViewPackages/developer_console.dart';

void _setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setTargetPlatformForDesktop();
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.settings);
  var a = await jsonSaver.readListData();
  if (a is Map) {
    Map<String, dynamic> retrieved = a;
    if (retrieved.length != settings.length) {
      Map<String, dynamic> tmp = Map();
      tmp.addAll(settings);
      tmp.addAll(retrieved);
      retrieved = tmp;
    }
    for (int i = 0; i < retrieved.length; i++) {
      retrieved[retrieved.keys.toList()[i]]['description'] =
          settings[retrieved.keys.toList()[i]]['description'];
    }
    settings.addAll(retrieved);
    (settings['Theme']['option']).forEach((k, v) {
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
  final ColorTheme themeSelected;
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
        "/settings": (context) => SettingsViewer(),
        '/devconsole': (context) => DeveloperConsole(),
        '/messages': (context) => MessageViewer(),
        '/credits': (context) => Credits()
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
  JSONSaver prevSavedAccount = JSONSaver(FilesAvailable.previouslySavedAccount);
  static int timesPressedSwitch = 0;

  void initState() {
    super.initState();
    _getPreviouslySavedDistrict();
    _getAccounts();
    _determineWhetherToLoginToPreviouslySavedAccount();
    _shouldShowWelcomeDialog();
    _checkSkyVars();
  }

  _checkSkyVars() async {
    await SkyVars.getVars();
    for (int i = 0; i < SkyVars.skyVarsDefault.length; i++) {
      if (!SkyVars.skyVars
          .containsKey(SkyVars.skyVarsDefault.keys.toList()[i])) {
        SkyVars.skyVars[SkyVars.skyVarsDefault.keys.toList()[i]] =
            SkyVars.skyVarsDefault.values.toList()[i];
      }
    }
    SkyVars.saveVars();
  }

  _shouldShowWelcomeDialog() async {
    JSONSaver jsonSaver = JSONSaver(FilesAvailable.firstTime);
    var ret = await jsonSaver.readListData();
    if (ret == null || ret == 0) {
      showDialog(
          context: context,
          builder: (c) => HuntyDialogForMoreText(
              title: 'Welcome!',
              description:
                  'Welcome to SkyMobile! To start off, login like you would login on regular Skyward, but make sure you have selected the correct district and inputted the corrct credentials. The search icon on the top is to search and select districts. If you have anymore questions you can press the information icon.',
              buttonText: 'Ok!'));
      jsonSaver.saveListData([false]);
    }
  }

  _determineWhetherToLoginToPreviouslySavedAccount() async {
    if (settings['Automatically Re-Load Last Saved Session']['option']) {
      var retrieved = await prevSavedAccount.readListData();
      if (retrieved.runtimeType != 0) {
        district = SkywardDistrict('No Name', retrieved['link']);
        _getGradeTerms(retrieved['user'], retrieved['pass']);
      }
    }
  }

  _getPreviouslySavedDistrict() async {
    JSONSaver jsonSaver = JSONSaver(FilesAvailable.previousDistrict);
    var districta = await jsonSaver.readListData();

    if (districta is SkywardDistrict)
      setState(() {
        district = districta;
      });
  }

  _saveDistrict() async {
    JSONSaver jsonSaver = JSONSaver(FilesAvailable.previousDistrict);
    await jsonSaver.saveListData(district);
  }

  _developerMode(String user, String pass) {
    gradeBoxes = [
      TeacherIDBox('Mr. Hayden', 'Biology AP', '6AM-6PM'),
      GradeBox('1', Term('AC1', 'Acredited AC1'), '99', '12345'),
      GradeBox('2', Term('AC2', 'Acredited AC2'), '98', '12345'),
      GradeBox('3', Term('AC3', 'Acredited AC3'), '99', '12345'),
      GradeBox('4', Term('AC4', 'Acredited AC4'), '98', '12345'),
      GradeBox('5', Term('AC5', 'Acredited AC5'), '99', '12345'),
      GradeBox('6', Term('WAN', 'Finale'), '98', '12345'),
      TeacherIDBox('Mr. Crenoptious', 'Heat', '6AM-6PM'),
      GradeBox('1', Term('AC1', 'Acredited AC1'), '105', '12345'),
      GradeBox('2', Term('AC2', 'Acredited AC2'), '103', '12345'),
      GradeBox('3', Term('AC3', 'Acredited AC3'), '9999', '12345'),
      GradeBox('4', Term('AC4', 'Acredited AC4'), '43', '12345'),
      GradeBox('5', Term('AC5', 'Acredited AC5'), '0', '12345'),
      GradeBox('6', Term('WAN', 'Finale'), '98', '12345'),
      TeacherIDBox('Mr. Jepolation', 'Cretonprechteja', '6AM-6PM'),
      GradeBox('1', Term('AC1', 'Acredited AC1'), '1', '12345'),
      GradeBox('2', Term('AC2', 'Acredited AC2'), '55', '12345'),
      GradeBox('3', Term('AC3', 'Acredited AC3'), '36', '12345'),
      GradeBox('4', Term('AC4', 'Acredited AC4'), '74', '12345'),
      GradeBox('5', Term('AC5', 'Acredited AC5'), '88', '12345'),
      GradeBox('6', Term('WAN', 'Finale'), '98', '12345'),
    ];
    terms = [
      Term('AC1', 'Acredited AC1'),
      Term('AC2', 'Acredited AC2'),
      Term('AC3', 'Acredited AC3'),
      Term('AC4', 'Acredited AC4'),
      Term('AC5', 'Acredited AC5'),
      Term('WAN', 'Finale'),
    ];
    currentChild = user;
    currentSessionIdentifier = pass;
    developerModeEnabled = true;
    Navigator.pushNamed(context, '/termviewer');
  }

  Map<String, String> developerAccountList = {'albaba': 'woaialbaba'};

  _getGradeTerms(String user, String pass) async {
    bool found = false;
    //如果输入的账号是DEVELOPER的，那进入开发人员模式
    developerAccountList.forEach((k, v) {
      if (user == k && pass == v) {
        _developerMode(user, pass);
        found = true;
      }
    });

    if (found) return;

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
            builder: (_) {
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
              builder: (_) {
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
      if (e.toString().contains('Invalid login or password')) {
        showDialog(
            context: context,
            builder: (_) {
              return HuntyDialog(
                  title: 'Uh-Oh',
                  description:
                      'Invalid Credentials or Internet Failure. Please check your username and password and your internet connection.',
                  buttonText: 'Ok');
            });
      } else
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
      if ((await skywardAPI.getSkywardAuthenticationCodes(
          acc.user, acc.pass))) {
        await getTermsAndGradeBook(isCancelled, dialog, acc);
      }
    } catch (e) {
      Navigator.of(context).pop(dialog);
      if (e.toString().contains('Invalid login or password')) {
        showDialog(
            context: context,
            builder: (_) {
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
      } else
        _underMaintence(context);
    }
  }

  int _indexOfKey(List<Widget> data, Key key) {
    return data.indexWhere((Widget d) => d.key == key);
  }

  Future getTermsAndGradeBook(
      List<bool> isCancelled, HuntyDialogLoading dialog, Account acc) async {
    try {
      await skywardAPI.initNewAccount();
      skywardAPI.switchUserIndex(1);
      var termRes = await skywardAPI.getGradeBookTerms();
      var gradebookRes = (await skywardAPI.getGradeBookGrades(termRes));
      terms = termRes;
      gradeBoxes = gradebookRes;
    } catch (e) {
      isCancelled[0] = true;
      Navigator.of(context).pop(dialog);
      await showDialog(
          context: context,
          builder: (_) {
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
      prevSavedAccount.saveListData(
          {'user': acc.user, 'pass': acc.pass, 'link': district.districtLink});
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
        })).then((val) {
      setState(() {});
    }).then((val) {
      _saveDistrict();
    });
  }

  TextEditingController _controllerUsername = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  bool isInAccountChooserStatus =
      settings['Default to Account Chooser']['option'];
  List<Account> accounts = [];

  //NOTE: USING THIS IS VERY BUGGY!!!!!
//  void _debugUseGenerateFakeAccounts(int numOfFakeAccounts) {
//    accounts = [];
//    for (int i = 0; i < numOfFakeAccounts; i++) {
//      accounts.add(Account(i.toString(), i.toString(), i.toString(),
//          SkywardDistrict('lol', 'ddd')));
//    }
//  }

  _getAccounts() async {
    if (await jsonSaver.doesFileExist()) {
      var unconverted = (await jsonSaver.readListData());
      if (unconverted is List) accounts = List<Account>.from(unconverted);
    } else {
      await jsonSaver.saveListData([]);
    }
    if (accounts.length == 0) {
      accounts.add(Account('You have no saved accounts', null, null, null));
    }
    setState(() {});
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
            saveSettingsData();
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
    if (ModalRoute.of(context).isCurrent) shouldBlur = false;
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
    Row utilRow = Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      IconButton(
        icon: Icon(
          Icons.info,
          color: themeManager.getColor(null),
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (c) => HuntyDialogForMoreText(
                  title: 'Information',
                  description:
                      'SkyMobile login page has a simple and intuitive design. The search button on the top indicates the district searcher. Use it to search and select different districts. The settings icon brings you to settings and the info dialog shows this dialog. Login like you would normally and press Choose Accounts to access your saved accounts.',
                  buttonText: 'Ok!'));
        },
      ),
      IconButton(
        icon: Icon(
          Icons.search,
          color: themeManager.getColor(null),
        ),
        onPressed: () {
          _showDialog();
        },
      ),
      IconButton(
        icon: Icon(
          Icons.settings,
          color: themeManager.getColor(null),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/settings');
        },
      ),
    ]);

    if (isInAccountChooserStatus) {
      List<Widget> widget = [];

      for (Account acc in accounts) {
        widget.add(Container(
            key: ValueKey(
                '${acc.user}${acc.district.districtName}${acc.pass.hashCode}'),
            padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 65),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                    splashColor: themeManager.getColor(TypeOfWidget.button),
                    borderRadius: BorderRadius.circular(16),
                    onTap: !(accounts.length > 0 &&
                            accounts.first.district == null)
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
                                    color: themeManager
                                        .getColor(TypeOfWidget.text)),
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
                                                          jsonSaver
                                                              .saveListData(
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
                                      _shouldAuthenticateAndContinue(acc,
                                          (acc) {
                                        TextEditingController accountEditor =
                                            TextEditingController();
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                HuntyDialogWithText(
                                                    hint: 'Edit Account',
                                                    textController:
                                                        accountEditor,
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
              ),
            )));
      }
      widget.add(SizedBox(
        key: ValueKey("RandSizedBox19928374"),
        height: 24,
      ));
      listView = ListView(shrinkWrap: true, children: <Widget>[
        ListTile(
            title: Container(
              child: Text('Accounts',
                  style: TextStyle(
                      color: themeManager.getColor(null),
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2)),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10, bottom: 10),
            ),
            trailing: utilRow),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10),
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
                    // widget.length > 5 ?
                    Container(
                        padding: EdgeInsets.only(bottom: 20, top: 20),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: 300, minHeight: 100),
                          //child: SingleChildScrollView(
                          child: ReorderableList(
                            onReorder: (Key item, Key newPosition) {
                              int draggingIndex = _indexOfKey(widget, item);
                              int newPositionIndex =
                                  _indexOfKey(widget, newPosition);

                              // Uncomment to allow only even target reorder possition
                              // if (newPositionIndex % 2 == 1)
                              //   return false;

                              final draggedItem = widget[draggingIndex];
                              setState(() {
                                debugPrint("Reordering $item -> $newPosition");
                                widget.removeAt(draggingIndex);
                                widget.insert(newPositionIndex, draggedItem);
                              });
                              return true;
                            },
                            child: CustomScrollView(slivers: [
                              SliverPadding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .padding
                                          .bottom),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        return Container(
                                          child: DelayedReorderableListener(
                                            child: widget.elementAt(index),
                                          ),
                                        );
                                      },
                                      childCount: widget.length,
                                    ),
                                  )),
                            ]),
                          ),
                          //)
                        )),
//                        : Container(
//                            padding: EdgeInsets.only(bottom: 20, top: 20),
//                            child: ReorderableListView(
//                                onReorder: (int k, int a) {
//                                  accounts.insert(
//                                      a > k ? a - 1 : a, accounts.removeAt(k));
//                                },
//                                children: widget)),
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
        ListTile(
            title: Container(
              child: Text('Login',
                  style: TextStyle(
                      color: themeManager.getColor(null),
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2)),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10, bottom: 10),
            ),
            trailing: utilRow),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10),
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
                          top: 20, left: 20, right: 20, bottom: 15),
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
                          top: 0, left: 20, right: 20, bottom: 10),
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
                                      _controllerPassword.text)
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
//                  new Container(
//                      padding: EdgeInsets.only(
//                          top: 0, left: 30, right: 30, bottom: 20),
//                      child: Material(
//                        color: Colors.transparent,
//                        child: InkWell(
//                            splashColor:
//                                themeManager.getColor(TypeOfWidget.button),
//                            borderRadius: BorderRadius.circular(16),
//                            onTap: () => {_showDialog()},
//                            child: Container(
//                              alignment: Alignment.center,
//                              padding: EdgeInsets.all(10),
//                              decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.circular(16.0),
//                                  border: Border.all(
//                                      color: themeManager
//                                          .getColor(TypeOfWidget.button),
//                                      width: 2)),
//                              child: new Text(
//                                'Search District',
//                                style: new TextStyle(
//                                    fontSize: 20.0,
//                                    color: themeManager
//                                        .getColor(TypeOfWidget.button)),
//                              ),
//                            )),
//                      )),
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
                                    timesPressedSwitch += 1;
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
          child: ScrollConfiguration(
            behavior: CustomOverscroll(),
            child: listView,
          ),
        )));
  }
}
