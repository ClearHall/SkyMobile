import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skymobile/Settings/themeColorManager.dart';
import 'package:skyscrapeapi/skywardAPITypes.dart';
import 'package:skymobile/HelperUtilities/globalVariables.dart';
import 'package:skymobile/HelperUtilities/customDialogOptions.dart';

class AssignmentsViewer extends StatefulWidget {
  MaterialColor secondColor;
  String courseName;

  AssignmentsViewer({this.secondColor, this.courseName});
  @override
  _AssignmentsViewerState createState() =>
      new _AssignmentsViewerState(courseName);
}

class _AssignmentsViewerState extends State<AssignmentsViewer> {
  String courseName;

  _AssignmentsViewerState(this.courseName);

  _goToAssignmentInfo(Assignment box) async {
    if (box.assignmentID != null) {
      bool isCancelled = false;
      var dialog = HuntyDialogLoading('Cancel', () {
        isCancelled = true;
      }, title: 'Loading', description: ('Getting your grades..'));

      showDialog(context: context, builder: (BuildContext context) => dialog)
          .then((val) {
        isCancelled = true;
      });

      try {
        var result = await skywardAPI.getAssignmentInfoFromAssignment(box);
        assignmentInfoBoxes = result;
      } catch (e) {
        Navigator.of(context).pop(dialog);
        String errMsg =
            'An error occured, please contact the developer: ${e.toString()}';

        showDialog(
            context: context,
            builder: (buildContext) {
              return HuntyDialog(
                  title: 'Uh Oh', description: errMsg, buttonText: 'Ok');
            });
        isCancelled = true;
      }

      if (!isCancelled) {
        Navigator.of(context, rootNavigator: true).popUntil((result) {
          return result.settings.name == '/assignmentsviewer';
        });
        Navigator.pushNamed(context, '/assignmentsinfoviewer');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> body = [];
    for (AssignmentsGridBox box in assignmentsGridBoxes) {
      bool isBoxCatHeader = box is CategoryHeader;
      String grade = isBoxCatHeader
          ? (box as CategoryHeader).getDecimal()
          : (box as Assignment).getDecimal();
      bool secondContNeeded =
          (isBoxCatHeader && (box as CategoryHeader).weight != null);

      body.add(Card(
        child: InkWell(
            onTap: () {
              if (box != null && box is Assignment) _goToAssignmentInfo(box);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width / 6 * 3.8),
                        padding: EdgeInsets.only(
                            top: 10,
                            left: 10,
                            right: 10,
                            bottom: secondContNeeded ? 0 : 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isBoxCatHeader
                              ? (box as CategoryHeader).catName
                              : (box as Assignment).assignmentName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isBoxCatHeader
                                  ? secondContNeeded
                                      ? themeManager.getColor(TypeOfWidget.text)
                                      : themeManager
                                          .getColor(TypeOfWidget.button)
                                  : Colors.white,
                              fontSize: isBoxCatHeader ? 20 : 15),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      secondContNeeded
                          ? Container(
                              constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width /
                                      6 *
                                      4.3),
                              padding: EdgeInsets.only(
                                  top: 5, left: 10, right: 10, bottom: 10),
                              alignment: Alignment.centerLeft,
                              child: Text((box as CategoryHeader).weight,
                                  style: TextStyle(
                                      color: themeManager
                                          .getColor(TypeOfWidget.text),
                                      fontSize: 15),
                                  textAlign: TextAlign.start),
                            )
                          : Container(
                              height: 0,
                            ),
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(minHeight: 60),
                  padding: EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  child: Text(
                    grade == null
                        ? box.attributes.containsKey('Points Earned')
                            ? box.attributes['Points Earned']
                            : ""
                        : grade,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: getColorFrom(grade)),
                  ),
                ),
              ],
            )),
        color: themeManager.getColor(TypeOfWidget.subBackground),
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
        ),
      ),
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
