import 'package:flutter/material.dart';
import 'SkywardScraperAPI/SkywardAPICore.dart';
import 'package:flutter/cupertino.dart';
import 'SkywardScraperAPI/SkywardAPITypes.dart';
import 'customDialogOptions.dart';
import 'globalVariables.dart';

class TermViewerPage extends StatefulWidget {
  MaterialColor secondColor;
  TermViewerPage({this.secondColor});
  @override
  _TermViewer createState() => new _TermViewer();
}

class _TermViewer extends State<TermViewerPage> {
  int currentTermIndex = 0;

  void _getGradeTerms(String user, String pass, BuildContext context) async {
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
      print(await skywardAPI
          .getGradeBookGrades(await skywardAPI.getGradeBookTerms()));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cupPickerWid = [];
    for (Term term in terms) {
      cupPickerWid.add(Container(
        child: Text('${term.termCode} / ${term.termName}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, color: Colors.white)),
        padding: EdgeInsets.only(top: 8),
      ));
    }

    List<Widget> body = [
      Container(
        child: Card(
          color: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Container(
            child: InkWell(
              child: Text(
                'Term: ${terms[currentTermIndex].termCode} / ${terms[currentTermIndex].termName}',
                style: TextStyle(fontSize: 15),
              ),
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) => CupertinoPicker(
                        backgroundColor: Colors.black,
                        children: cupPickerWid,
                        itemExtent: 50,
                        onSelectedItemChanged: (int changeTo) {
                          setState(() {
                            currentTermIndex = changeTo;
                          });
                        }));
              },
            ),
            padding: EdgeInsets.all(10),
          ),
        ),
        padding: EdgeInsets.all(10),
      ),
    ];

    for (int i = 0; i < gradeBoxes.length; i++) {
      if (gradeBoxes[i] is TeacherIDBox) {
        int indexOfTermGrade = -1;
        for (int j = i + 1; j < gradeBoxes.length; j++) {
          if (gradeBoxes[j] is GradeBox &&
              (gradeBoxes[j] as GradeBox).term == terms[currentTermIndex]) {
            indexOfTermGrade = j;
            break;
          }
        }
        TeacherIDBox teacherIDBox = gradeBoxes[i] as TeacherIDBox;
        GradeBox gradeBox;
        if (indexOfTermGrade != -1) {
          gradeBox = gradeBoxes[indexOfTermGrade] as GradeBox;
        }

        body.add(Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width/6 * 4),
                      padding: EdgeInsets.only(
                          top: 10, left: 10, right: 10, bottom: 0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        teacherIDBox.courseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: 5, left: 10, right: 10, bottom: 0),
                      alignment: Alignment.centerLeft,
                      child: Text(teacherIDBox.teacherName,
                          style: TextStyle(color: Colors.white, fontSize: 15),
                          textAlign: TextAlign.start),
                    ),
                    Container(
                        padding: EdgeInsets.only(
                            top: 5, left: 10, right: 10, bottom: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(teacherIDBox.timePeriod,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                            textAlign: TextAlign.start))
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(minHeight: 60),
                padding: EdgeInsets.all(10),
                alignment: Alignment.centerRight,
                child: Text('TEST', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.lightGreen),),
              ),
            ],
          ),
          color: Colors.white12,
        ));
      }
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text('Gradebook',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2)),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: ListView(
            padding: EdgeInsets.all(10),
            children: body,
          ),
        ));
  }
}
