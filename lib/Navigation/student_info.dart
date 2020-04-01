import 'package:flutter/material.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skymobile/SupportWidgets/biometric_blur_view.dart';
import 'package:skymobile/main.dart';
import 'package:skyscrapeapi/data_types.dart';

class StudentInfoPage extends StatefulWidget {
  final List args;

  StudentInfoPage(this.args);

  @override
  _StudentInfo createState() => _StudentInfo(args[0]);
}

class _StudentInfo extends BiometricBlur<StudentInfoPage> {
  StudentInfo info;

  _StudentInfo(this.info);

  @override
  Widget generateBody(BuildContext context) {
    String stuin = '';

    info.studentAttributes.forEach((key, value) {
      if (key.endsWith(':')) {
        stuin += (key + ' ' + value ?? '') + '\n';
      }
    });

    String schoolinfo = '';

    info.currentSchool.attributes.forEach((key, value) {
      if (key.endsWith(':')) {
        schoolinfo += (key + ' ' + value ?? '') + '\n';
      }
    });

    List<InfoBox> box = List();

    for(Family e in info.family){
      String einfo = '';
      e.extraInfo.forEach((key, value) {
        if(value == 'true' || value == 'false')
          einfo += (key + ': ' + (value == 'true' ? 'Yes' : 'No') ?? '') + '\n';
        else if(key.endsWith(':'))
          einfo += (key + ' ' + value ?? '') + '\n';
        else
          einfo += (key + ': ' + value ?? '') + '\n';
      });
      box.add(InfoBox('My Family', einfo));

      for(Guardian g in e.guardians){
        einfo = '';
        g.extraInfo.forEach((key, value) {
          einfo += (key + ': ' + value ?? '') + '\n';
        });
        box.add(InfoBox('Guardian ' + g.guardianName, einfo));
      }
    }

    for(EmergencyContact e in info.emergencyContacts){
      String einfo = '';
      e.attributes.forEach((key, value) {
          einfo += (key + ': ' + value ?? '') + '\n';
      });
      box.add(InfoBox('Emergency Contact ' + e.name, einfo));
    }


    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: themeManager.getColor(TypeOfWidget.text), size: 30),
          backgroundColor: themeManager.getColor(TypeOfWidget.background),
          title: Align(
              alignment: Alignment.center,
              child: FittedBox(
                  child: Text(neiceban ? '内测版' : info.name,
                      style: TextStyle(
                        color: themeManager.getColor(TypeOfWidget.text),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      )))),
          actions: <Widget>[
            SizedBox(
              width: 60,
            )
          ],
        ),
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        body: Center(
          child: ListView(
            children: <Widget>[
              info.studentAttributes.containsKey('Student Image Href Link')
                  ? ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: 100, maxHeight: 150),
                      child: Image.network(
                        info.studentAttributes['Student Image Href Link']
                            .substring(MyHomePageState.skywardURLPrefix.length),
                      ))
                  : Container(),
              InfoBox('My Info', stuin, topPad: 10,),
              InfoBox(info.currentSchool.schoolName + ' School', schoolinfo),
              ...box
            ],
          ),
        ));
  }
}

class InfoBox extends Container{
  final String title;
  final String desc;
  final double topPad;

  InfoBox(this.title, this.desc, {this.topPad});

  @override
  Widget build(BuildContext context) {
    return
      Container(
          padding:
          EdgeInsets.only(top: topPad ?? 0, left: 20, right: 20, bottom: 10),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            color: themeManager.getColor(TypeOfWidget.subBackground),
            child: Container(
                padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                child: Column(
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          color:
                          themeManager.getColor(TypeOfWidget.text),
                          fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        desc,
                        style: TextStyle(
                            color: themeManager
                                .getColor(TypeOfWidget.text),
                            fontSize: 15),
                        maxLines: 25,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )),
          ));
  }
}