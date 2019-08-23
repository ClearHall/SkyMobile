import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'SkywardScraperAPI/SkywardAPICore.dart';
import 'SkywardScraperAPI/SkywardAPITypes.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _incrementCounter() async {
    var skywardAPI = SkywardAPICore('https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/');
    await skywardAPI.getSkywardAuthenticationCodes('711741', 'baofa0607');
    var terms = (await skywardAPI.getGradeBookTerms());
    var gradeBoxes = await skywardAPI.getGradeBookGrades(terms);
    debugPrint(terms.toString());
    print(gradeBoxes);
    //debugPrint(await skywardAPI.getAssignmentsFromCourseAndTerm(gradeBoxes[1]));
  }

  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl:
              'https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w',
          onWebViewCreated: (WebViewController webViewController) {
            _controller = webViewController;
          }),
      floatingActionButton: FloatingActionButton(onPressed: _incrementCounter),
    );
  }
}
