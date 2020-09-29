import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:skymobile/ExtraViewPackages/credits.dart';
import 'package:skymobile/ExtraViewPackages/developer_console.dart';
import 'package:skymobile/GPACalculator/classes.dart';
import 'package:skymobile/GPACalculator/school_year.dart';
import 'package:skymobile/GPACalculator/settings.dart';
import 'package:skymobile/HelperUtilities/DataPersist/json_saver.dart';
import 'package:skymobile/HelperUtilities/DataPersist/manage_sky_vars.dart';
import 'package:skymobile/HelperUtilities/account_types.dart';
import 'package:skymobile/Navigation//gradebook.dart';
import 'package:skymobile/Navigation/assignment_info.dart';
import 'package:skymobile/Navigation/assignments.dart';
import 'package:skymobile/Navigation/messages.dart';
import 'package:skymobile/Navigation/student_info.dart';
import 'package:skymobile/Settings/settings_viewer.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skymobile/SupportWidgets/biometric_blur_view.dart';
import 'package:skymobile/SupportWidgets/custom_overscroll_behavior.dart';
import 'package:skymobile/SupportWidgets/flutter_reorderable_list.dart';
import 'package:skyscrapeapi/sky_core.dart';

import 'ExtraViewPackages/hunty_dialogs.dart';
import 'HelperUtilities/global.dart';

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
  if (!kIsWeb) {
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
      bool found = false;
      (settings['Theme']['option']).forEach((k, v) {
        found = found || v;
        if (v == true)
          runApp(MyApp(ThemeManager.colorNameToThemes.keys.toList()[
          ThemeManager.colorNameToThemes.values.toList().indexOf(k)]));
      });
      if (!found) runApp(MyApp(settings['Custom Theme']['option']));
    } else {
      settings['Theme']['option']
      [ThemeManager.colorNameToThemes[themeManager.currentTheme]] = true;
      runApp(MyApp(themeManager.currentTheme));
    }
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
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: RemoveScrollGlow(),
          child: child,
        );
      },
      title: 'SkyMobile',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => MyHomePage(),
        "/termviewer": (context) =>
            TermViewerPage(ModalRoute.of(context).settings.arguments),
        "/assignmentsviewer": (context) =>
            AssignmentsViewer(ModalRoute.of(context).settings.arguments),
        "/assignmentsinfoviewer": (context) =>
            AssignmentInfoViewer(ModalRoute.of(context).settings.arguments),
        "/gpacalculatorschoolyear": (context) =>
            GPACalculatorSchoolYear(ModalRoute.of(context).settings.arguments),
        "/gpacalculatorclasses": (context) =>
            GPACalculatorClasses(ModalRoute.of(context).settings.arguments),
        "/gpacalculatorsettings": (context) =>
            GPACalculatorSettings(ModalRoute.of(context).settings.arguments),
        "/settings": (context) => SettingsViewer(),
        '/devconsole': (context) => DeveloperConsole(),
        '/messages': (context) =>
            MessageViewer(ModalRoute.of(context).settings.arguments),
        '/credits': (context) => Credits(),
        '/studentinfo': (context) =>
            StudentInfoPage(ModalRoute
                .of(context)
                .settings
                .arguments)
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
  static final String skywardURLPrefix =
  kIsWeb ? 'https://cors-anywhere.herokuapp.com/' : '';
  JSONSaver jsonSaver = JSONSaver(FilesAvailable.accounts);
  static SkywardDistrict district = SkywardDistrict('FORT BEND ISD',
      'https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w');
  static List<Account> accounts = [];
  final _auth = LocalAuthentication();
  JSONSaver prevSavedAccount = JSONSaver(FilesAvailable.previouslySavedAccount);
  static int timesPressedSwitch = 0;

  initState() {
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

  Future<List> _getValAcc() async {
    var unconverted = jsonSaver.readListData();
    var tmp1 = await unconverted;
    return tmp1;
  }

  _getAccounts() async {
    if (await jsonSaver.doesFileExist()) {
      List tmp2 = await _getValAcc();
      accounts = tmp2.cast<Account>();
    } else {
      await jsonSaver.saveListData([]);
    }
    if (accounts.length == 0) {
      accounts.add(Account('You have no saved accounts', null, null, null));
    }
    if (kIsWeb)
      showDialog(
          context: context,
          builder: (c) =>
              HuntyDialog(
                  title: 'Account Saving',
                  description:
                  'It looks like you are using the SkyMobile demo. Account saving will be local.',
                  buttonText: 'Ok!'));
    setState(() {});
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
              'Welcome to SkyMobile! To start off, login like you would on regular Skyward, but make sure you have selected the correct district. The search icon on the top allows you to search and select districts. For more information, press the info icon.',
              buttonText: 'Ok!'));
      try {
        jsonSaver.saveListData([false]);
      } catch (e) {
        print(e);
      }
    }
  }

  _determineWhetherToLoginToPreviouslySavedAccount() async {
    if (settings['Automatically Re-Load Last Saved Session']['option']) {
      var retrieved = await prevSavedAccount.readListData();
      if (retrieved.runtimeType != 0) {
        district = SkywardDistrict('No Name', retrieved['link']);
        _login(Account(null, retrieved['user'], retrieved['pass'], district));
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
    Gradebook gradebook = Gradebook([GradebookSector()]);
    List<Term> terms = [
      Term('AC1', 'Application AC1'),
      Term('AC2', 'Application AC2'),
      Term('AC3', 'Application AC3'),
      Term('AC4', 'Application AC4'),
      Term('AC5', 'Application AC5'),
      Term('WAN', 'Finale'),
    ];

    Random rand = Random();
    String studentID = '3099';
    gradebook.gradebookSectors.first.classes = [
      Class('Mr. Hayden', '6AM-6PM', 'Biology AP', "0", grades: [
        Grade('1', terms[0], rand.nextInt(101).toString(), studentID, "0", "0"),
        Grade('2', terms[1], rand.nextInt(101).toString(), studentID, "1", "0"),
        Grade('3', terms[2], rand.nextInt(101).toString(), studentID, "2", "0"),
        Grade('4', terms[3], rand.nextInt(101).toString(), studentID, "3", "0"),
        Grade('5', terms[4], rand.nextInt(101).toString(), studentID, "4", "0"),
        Grade('6', terms[5], rand.nextInt(101).toString(), studentID, "5", "0"),
      ]),
      Class('Mr. Crenp', '6AM-6PM', 'Heat AP', "1", grades: [
        Grade('1', terms[0], rand.nextInt(101).toString(), studentID, "0", "0"),
        Grade('2', terms[1], rand.nextInt(101).toString(), studentID, "1", "0"),
        Grade('3', terms[2], rand.nextInt(101).toString(), studentID, "2", "0"),
        Grade('4', terms[3], rand.nextInt(101).toString(), studentID, "3", "0"),
        Grade('5', terms[4], rand.nextInt(101).toString(), studentID, "4", "0"),
        Grade('6', terms[5], rand.nextInt(101).toString(), studentID, "5", "0"),
      ]),
      Class('Mrs. Applenack', '6AM-6PM', 'Chinese AP', "2", grades: [
        Grade('1', terms[0], rand.nextInt(101).toString(), studentID, "0", "0"),
        Grade('2', terms[1], rand.nextInt(101).toString(), studentID, "1", "0"),
        Grade('3', terms[2], rand.nextInt(101).toString(), studentID, "2", "0"),
        Grade('4', terms[3], rand.nextInt(101).toString(), studentID, "3", "0"),
        Grade('5', terms[4], rand.nextInt(101).toString(), studentID, "4", "0"),
        Grade('6', terms[5], rand.nextInt(101).toString(), studentID, "5", "0"),
      ]),
    ];

    currentChild = user;
    currentSessionIdentifier = pass;
    Navigator.pushNamed(context, '/termviewer',
        arguments: [gradebook, 'Tester Dev', true])
        .then((value) => setState(() {}));
  }

  Map<String, String> developerAccountList = {'albaba': 'woaialbaba'};

  _login(Account acc) async {
    bool found = false;
    developerAccountList.forEach((k, v) {
      if (acc.user == k && acc.pass == v) {
        _developerMode(acc.user, acc.pass);
        found = true;
      }
    });

    if (found) return;

    List<bool> isCancelled = [false];
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled[0] = true;
    },
        title: 'Loading',
        description: ('Please wait...' +
            (kIsWeb
                ? '\nThis will take longer because you are using the web demo!'
                : '')));

    showDialog(context: context, builder: (BuildContext context) => dialog)
        .then((val) {
      isCancelled[0] = true;
    });

    try {
      User person = await SkyCore.login(
          acc.user, acc.pass, skywardURLPrefix + acc.district.districtLink);
      var gradebookRes = await person.getGradebook();
      String meinName = await person.getName();

      if (!isInAccountChooserStatus && !_isCredentialsSavedAlready(acc.user)) {
        await showDialog(
            context: context,
            builder: (_) {
              return HuntyDialogForConfirmation(
                title: 'New Account',
                description:
                'Would you like to save this account?',
                runIfUserConfirms: () {
                  setState(() {
                    acc.nick = meinName ?? acc.user;
                    accounts.add(acc);
                    jsonSaver.saveListData(accounts);
                  });
                },
                btnTextForCancel: "Cancel",
                btnTextForConfirmation: 'Ok',
              );
            });
      }

      if (!(isCancelled.first)) {
        currentSessionIdentifier = acc.user;
        prevSavedAccount.saveListData({
          'user': acc.user,
          'pass': acc.pass,
          'link': district.districtLink
        });
        account = person;
        Navigator.pushNamed(context, '/termviewer',
            arguments: [gradebookRes, meinName, false])
            .then((value) =>
            setState(() {
              Navigator.of(context)
                  .popUntil((route) => route.settings.name == '/');
            }));
      }
    } catch (e) {
      Navigator.of(context).popUntil((route) => route.settings.name == '/');
      if (isInAccountChooserStatus &&
          e.toString().contains('Invalid login or password')) {
        showDialog(
            context: context,
            builder: (_) {
              return HuntyDialogForConfirmation(
                title: 'Login Error',
                description:
                'Invalid Credentials or Internet Failure. Would you like to remove this account?',
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
        showDialog(
            context: context,
            builder: (_) {
              return HuntyDialog(
                  title: 'Login Error',
                  description:
                  e.toString() + ' Check your internet connection!',
                  buttonText: 'Ok');
            });
      }
    }
  }

  bool _isCredentialsSavedAlready(String user) {
    for (Account acc in accounts) {
      if (acc.district == district && acc.user == user) return true;
    }
    return false;
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

  //NOTE: USING THIS IS VERY BUGGY!!!!!
//  void _debugUseGenerateFakeAccounts(int numOfFakeAccounts) {
//    accounts = [];
//    for (int i = 0; i < numOfFakeAccounts; i++) {
//      accounts.add(Account(i.toString(), i.toString(), i.toString(),
//          SkywardDistrict('lol', 'ddd')));
//    }
//  }

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
                        '\nSkyMobile will disable authentication.',
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
                  description: isInAccountChooserStatus
                      ? 'Long press to reorder accounts.'
                      : 'The login page is designed to be simple and intuitive. The search button allows you to search and select different districts, the settings icon brings you to the settings page, and the info button shows this dialog. Select Choose Accounts to access your saved accounts.',
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
          Navigator.of(context)
              .pushNamed('/settings')
              .then((value) => setState(() {}));
        },
      ),
    ]);

    if (isInAccountChooserStatus) {
      List<Widget> widget = [];

      for (Account acc in accounts) {
        widget.add(ReorderableItem(
          key: ValueKey(
              '${acc.user}${acc.district != null ? acc.district.districtName : acc.district}${acc.pass.hashCode}'),
          childBuilder: (BuildContext context, ReorderableItemState state) =>
              DelayedReorderableListener(
                child: Opacity(
                  opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
                  child: Container(
                      padding:
                      EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 65),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                              splashColor:
                              themeManager.getColor(TypeOfWidget.button),
                              borderRadius: BorderRadius.circular(16),
                              onTap: !(accounts.length > 0 &&
                                  accounts.first.district == null)
                                  ? () {
                                focus.unfocus();
                                _shouldAuthenticateAndContinue(acc, _login);
                              }
                                  : () => {},
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                        color: themeManager
                                            .getColor(TypeOfWidget.text),
                                        width: 2)),
                                child: accounts.length > 0 &&
                                    accounts.first.district == null
                                    ? ListTile(
                                    title: Text(
                                      acc.nick,
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          color: themeManager
                                              .getColor(TypeOfWidget.text)),
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
                                              color:
                                              themeManager.getColor(null),
                                            ),
                                            onPressed: () {
                                              _shouldAuthenticateAndContinue(
                                                  acc, (acc) {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                    context) =>
                                                        HuntyDialogForConfirmation(
                                                            title:
                                                            'Account Deletion',
                                                            description:
                                                            'Are you sure you want to remove this account?',
                                                            runIfUserConfirms:
                                                                () {
                                                              setState(() {
                                                                accounts.remove(
                                                                    acc);
                                                                jsonSaver
                                                                    .saveListData(
                                                                    accounts);
                                                              });
                                                            },
                                                            btnTextForConfirmation:
                                                            'Yes',
                                                            btnTextForCancel:
                                                            'No'));
                                              });
                                            }),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          color: themeManager.getColor(null),
                                          onPressed: () {
                                            _shouldAuthenticateAndContinue(acc,
                                                    (acc) {
                                                  TextEditingController
                                                  accountEditor =
                                                  TextEditingController();
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                      context) =>
                                                          HuntyDialogWithText(
                                                              hint: 'Edit Account',
                                                              textController:
                                                              accountEditor,
                                                              okPressed: () {
                                                                setState(() {
                                                                  acc.nick =
                                                                      accountEditor
                                                                          .text;
                                                                  jsonSaver
                                                                      .saveListData(
                                                                      accounts);
                                                                });
                                                              },
                                                              title:
                                                              'Edit Account Name',
                                                              description:
                                                              'Type in a new account name to be displayed. This does not affect logging in and logging out.',
                                                              buttonText:
                                                              'Submit'));
                                                });
                                          },
                                        )
                                      ],
                                    )),
                              )),
                        ),
                      )),
                ),
              ),
        ));
      }
      listView = ListView(shrinkWrap: true, children: <Widget>[
        ListTile(
            title: Container(
              child: Text(neiceban ? '内测版' : 'Accounts',
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
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    // widget.length > 5 ?
                    ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20, top: 20),
                          child: ReorderableList(
                            onReorder: (Key item, Key newPosition) {
                              int draggingIndex = indexOfKey(widget, item);
                              int newPositionIndex =
                              indexOfKey(widget, newPosition);

                              final draggedItem = accounts[draggingIndex];
                              setState(() {
                                debugPrint(
                                    "Reordering $draggingIndex -> $newPositionIndex");
                                accounts.removeAt(draggingIndex);
                                accounts.insert(newPositionIndex, draggedItem);
                              });
                              return true;
                            },
                            onReorderDone: (Key item) {
                              final draggedItem =
                              widget[indexOfKey(widget, item)];
                              debugPrint(
                                  "Reordering finished for ${draggedItem.key}}");
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
                                        return widget.elementAt(index);
                                      },
                                      childCount: widget.length,
                                    ),
                                  )),
                            ]),
                            //)
                          ),
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
      listView = ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
                title: Container(
                  child: Text(neiceban ? '内测版' : 'Login',
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
                              'Enter your Skyward Credentials for ${district
                                  .districtName}.',
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
                            style:
                            TextStyle(color: themeManager.getColor(null)),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(18),
                                labelText: "Username",
                                labelStyle: TextStyle(
                                    color: themeManager
                                        .getColor(TypeOfWidget.text)),
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
                            style:
                            TextStyle(color: themeManager.getColor(null)),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(18),
                                labelText: "Password",
                                labelStyle: TextStyle(
                                    color: themeManager
                                        .getColor(TypeOfWidget.text)),
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
                                onTap: () =>
                                {
                                  focus.unfocus(),
                                  _login(Account(
                                      null,
                                      _controllerUsername.text,
                                      _controllerPassword.text,
                                      district))
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
                              top: 0, left: 30, right: 30, bottom: 25),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                                splashColor:
                                themeManager.getColor(TypeOfWidget.text),
                                borderRadius: BorderRadius.circular(16),
                                onTap: () =>
                                {
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
    Widget wid = Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      child: ScrollConfiguration(
        behavior: CustomOverscroll(),
        child: listView,
      ),
    );

    return Scaffold(
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        body: Center(
            child: kIsWeb || debugDefaultTargetPlatformOverride != null
                ? ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 650), child: wid,)
                : wid));
  }
}

class RemoveScrollGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
