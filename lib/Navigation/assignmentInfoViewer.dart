import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skymobile/HelperUtilities/themeColorManager.dart';
import 'package:skyscrapeapi/skywardAPITypes.dart';
import 'package:skymobile/HelperUtilities/globalVariables.dart';

class AssignmentInfoViewer extends StatefulWidget {
  MaterialColor secondColor;
  String courseName;

  AssignmentInfoViewer({this.secondColor, this.courseName});
  @override
  _AssignmentInfoViewerState createState() =>
      new _AssignmentInfoViewerState(courseName);
}

class _AssignmentInfoViewerState extends State<AssignmentInfoViewer> {
  String courseName;

  _AssignmentInfoViewerState(this.courseName);

  @override
  Widget build(BuildContext context) {
    List<Widget> body = [];
    for (AssignmentInfoBox box in assignmentInfoBoxes) {
      String uiMessage = box.getUIMessage();
      body.add(Card(
        color: themeManager.getColor(TypeOfWidget.subBackground),
        child: Container(
          alignment: Alignment.centerLeft,
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 6 * 4.4),
          padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
          child: Text(
            uiMessage,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: themeManager.getColor(TypeOfWidget.text), fontSize: 20),
            textAlign: TextAlign.start,
          ),
        ),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
        color: themeManager.getColor(TypeOfWidget.text), size: 30),
    backgroundColor: themeManager.getColor(TypeOfWidget.background),
    title: Align(
    alignment: Alignment.centerLeft,
    child: Text(courseName != null ? courseName : 'Assignments',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: themeManager.getColor(TypeOfWidget.text),
                fontSize: 30,
                fontWeight: FontWeight.w700)),
      ),),
      backgroundColor: Colors.black,
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: body,
        ),
      ),
    );
  }
}
