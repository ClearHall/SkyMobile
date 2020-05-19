import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skymobile/SupportWidgets/biometric_blur_view.dart';
import 'package:skyscrapeapi/sky_core.dart';

class AssignmentInfoViewer extends StatefulWidget {
  final List args;

  AssignmentInfoViewer(this.args);
  @override
  _AssignmentInfoViewerState createState() =>
      new _AssignmentInfoViewerState(args[0], args[1]);
}

class _AssignmentInfoViewerState extends BiometricBlur<AssignmentInfoViewer> {
  String courseName;
  List<AssignmentProperty> props;

  _AssignmentInfoViewerState(this.courseName, this.props);

  @override
  Widget generateBody(BuildContext context) {
    if (shouldBlur)
      return Scaffold(
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
      );
    List<Widget> body = [];
    int ind = 0;
    for (AssignmentProperty box in props) {
      if(ind <= 1 || (!settings['Hidden Empty Assignment Properties']['option'] || (box.info != null && box.info.trim().isNotEmpty))) {
        String uiMessage = box.toString();
        body.add(Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          color: themeManager.getColor(TypeOfWidget.subBackground),
          child: Container(
            alignment: Alignment.centerLeft,
//            constraints: BoxConstraints(
//                maxWidth: MediaQuery
//                    .of(context)
//                    .size
//                    .width / 6 * 4.4),
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
            child: Text(
              uiMessage,
              maxLines: 15,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: themeManager.getColor(TypeOfWidget.text),
                  fontSize: 20),
              textAlign: TextAlign.start,
            ),
          ),
        ));
        ind++;
      }
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: themeManager.getColor(TypeOfWidget.text), size: 30),
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(neiceban ? '内测版' : (courseName != null ? courseName : 'Assignments'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: themeManager.getColor(TypeOfWidget.text),
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
        ),
      ),
      backgroundColor: themeManager.getColor(TypeOfWidget.background),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: body,
        ),
      ),
    );
  }
}
