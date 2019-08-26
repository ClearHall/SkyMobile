import 'package:flutter/material.dart';
import 'SkywardScraperAPI/SkywardAPICore.dart';
import 'termGradeViewer.dart';
import 'customDialogOptions.dart';
import 'globalVariables.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyMobile',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: MyHomePage(title: 'SkyMobile'),
      debugShowCheckedModeBanner: false,
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
  Stream<List> dataSub;

  void _incrementCounter() async {
    var terms = (await skywardAPI.getGradeBookTerms());
    var gradeBoxes = await skywardAPI.getGradeBookGrades(terms);
    var assignmentBoxes =
        await skywardAPI.getAssignmentsFromGradeBox(gradeBoxes[1]);
    print(gradeBoxes);
    print(assignmentBoxes);
    print(await skywardAPI.getAssignmentInfoFromAssignment(assignmentBoxes[1]));
  }

  void _getGradeTerms(String user, String pass, BuildContext context) async {
    bool isCancelled = false;
    var dialog = HuntyDialogLoading('Cancel', () {
      isCancelled = true;
    }, title: 'Loading', description: ('Getting your grades..'));

    showDialog(
        context: context,
        builder: (BuildContext context) => dialog);

    skywardAPI = SkywardAPICore(
        'https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/');
    if (await skywardAPI.getSkywardAuthenticationCodes(user, pass) ==
        SkywardAPICodes.LoginFailed) {
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
      terms = await skywardAPI.getGradeBookTerms();
      gradeBoxes = (await skywardAPI.getGradeBookGrades(terms));
      var tm = TermViewerPage();
      if(!isCancelled) {
        Navigator.of(context, rootNavigator: true).popUntil((result){
          return result.settings.name == '/';
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => (tm)));
      }
    }
  }

  TextEditingController _controllerUsername = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final focus = FocusNode();

    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: ListView(shrinkWrap: true, children: <Widget>[
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
                            padding: EdgeInsets.only(
                                top: 20, left: 30, right: 30, bottom: 0),
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              child: new Text(
                                'Enter your Skyward Credentials for FORT BEND ISD.',
                                style: new TextStyle(
                                    fontSize: 20.0, color: Colors.white),
                              ),
                            )),
                        Container(
                            padding: EdgeInsets.only(
                                top: 20, left: 16, right: 16, bottom: 15),
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              autofocus: true,
                              controller: _controllerUsername,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(18),
                                  labelText: "Username",
                                  labelStyle: TextStyle(color: Colors.blue),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2),
                                      borderRadius: BorderRadius.circular(16)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2),
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
                              autofocus: true,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(18),
                                  labelText: "Password",
                                  labelStyle: TextStyle(color: Colors.blue),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2),
                                      borderRadius: BorderRadius.circular(16)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2),
                                      borderRadius: BorderRadius.circular(16))),
                              onFieldSubmitted: (v) {
                                focus.unfocus();
                              },
                            )),
                        new Container(
                            padding: EdgeInsets.only(
                                top: 20, left: 30, right: 30, bottom: 20),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  splashColor: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => {
                                        _getGradeTerms(_controllerUsername.text,
                                            _controllerPassword.text, context)
                                      },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                            color: Colors.orangeAccent,
                                            width: 2)),
                                    child: new Text(
                                      'Submit',
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.orangeAccent),
                                    ),
                                  )),
                            )),
                      ]))
                ]))));
  }
}
