import 'package:flutter/material.dart';
import 'SkywardScraperAPI/SkywardAPICore.dart';
import 'SkywardScraperAPI/SkywardAPITypes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _incrementCounter() async {
    var skywardAPI = SkywardAPICore('https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/');
    await skywardAPI.getSkywardAuthenticationCodes('753495', 'ym040722');
    await skywardAPI.getSkywardAuthenticationCodes('602353', '009372');
    var terms = (await skywardAPI.getGradeBookTerms());
    var gradeBoxes = await skywardAPI.getGradeBookGrades(terms);
    var assignmentBoxes = await skywardAPI.getAssignmentsFromGradeBox(gradeBoxes[1]);
    print(gradeBoxes);
    print(assignmentBoxes);
    print(await skywardAPI.getAssignmentInfoFromAssignment(assignmentBoxes[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(children: <Widget>[],),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _incrementCounter),
    );
  }
}
