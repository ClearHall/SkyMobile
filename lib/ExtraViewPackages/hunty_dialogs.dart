import 'package:flutter/material.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skyscrapeapi/district_searcher.dart';
import 'package:skyscrapeapi/data_types.dart';
import '../main.dart';
import '../HelperUtilities/global.dart';

class HuntyDialog extends StatelessWidget {
  final String title, description, buttonText;

  HuntyDialog(
      {@required this.title,
      @required this.description,
      @required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: customDialogContent(context),
    );
  }

  createDialogBoxContents(BuildContext context) {
    return <Widget>[
      Text(
        title,
        style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: themeManager.getColor(null)),
      ),
      SizedBox(height: 16.0),
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: themeManager.getColor(null)),
      ),
      SizedBox(height: 24.0),
      Align(
        alignment: Alignment.bottomRight,
        child: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            buttonText,
            style: TextStyle(color: themeManager.getColor(null)),
          ),
        ),
      ),
    ];
  }

  customDialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(top: 16.0 + 66, bottom: 16, left: 15, right: 16),
          margin: EdgeInsets.only(top: 66),
          decoration: new BoxDecoration(
            border: Border.all(color: themeManager.getColor(TypeOfWidget.text)),
            color: themeManager.getColor(TypeOfWidget.background),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: createDialogBoxContents(context),
          ),
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class HuntyDialogLoading extends HuntyDialog {
  final String cancelText;
  final Function runWhenCancelled;
  bool restrictCancel = false;
  HuntyDialogLoading(this.cancelText, this.runWhenCancelled,
      {@required title, @required description})
      : super(title: title, description: description, buttonText: null);

  @override
  createDialogBoxContents(BuildContext context) {
    return <Widget>[
      Text(
        title,
        style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: themeManager.getColor(null)),
      ),
      SizedBox(height: 16.0),
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: themeManager.getColor(null)),
      ),
      SizedBox(height: 24.0),
      CircularProgressIndicator(),
      SizedBox(height: 40.0),
      restrictCancel
          ? Container()
          : Align(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  runWhenCancelled();
                },
                child: Text(
                  cancelText,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
    ];
  }
}

class HuntyDistrictSearcherWidget extends StatefulWidget {
  HuntyDistrictSearcherWidget({this.title, this.description, this.buttonText});

  final String title, description, buttonText;

  @override
  _HuntyDistrictSearcherWidgetState createState() =>
      _HuntyDistrictSearcherWidgetState(
          title: title, description: description, buttonText: buttonText);
}

class _HuntyDistrictSearcherWidgetState
    extends State<HuntyDistrictSearcherWidget> {
  final String title, description, buttonText;

  _HuntyDistrictSearcherWidgetState(
      {@required this.title,
      @required this.description,
      @required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: customDialogContent(context),
    );
  }

  var dropDownVal = SkywardDistrictSearcher.states[0].stateID;
  var textController = TextEditingController();
  List<SkywardDistrict> districtsFromSearchQuery = [];
  Widget messages;

  createDialogBoxContents(BuildContext context) {
    List<Widget> districtCards = [];
    for (SkywardDistrict district in districtsFromSearchQuery) {
      districtCards.add(Container(
        child: Card(
            color: Colors.white10,
            child: InkWell(
                onTap: () {
                  MyHomePageState.district = district;
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    district.districtName,
                    style: TextStyle(color: Colors.white),
                  ),
                ))),
        height: 100,
        width: 130,
      ));
    }

    return <Widget>[
      Text(
        title,
        style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: themeManager.getColor(TypeOfWidget.button)),
      ),
      SizedBox(height: 16.0),
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      SizedBox(height: 10.0),
      new Theme(
          data: Theme.of(context).copyWith(
              canvasColor: themeManager.getColor(TypeOfWidget.background)),
          child: DropdownButton<String>(
            items: SkywardDistrictSearcher.states
                .map<DropdownMenuItem<String>>((SkywardSearchState value) {
              return DropdownMenuItem<String>(
                value: value.stateID,
                child: Text(
                  value.stateName,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            value: dropDownVal,
            onChanged: (String newVal) {
              setState(() {
                dropDownVal = newVal;
              });
            },
          )),
      Container(
        padding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
        child: TextField(
          textAlign: TextAlign.center,
          controller: textController,
          style: TextStyle(color: themeManager.getColor(TypeOfWidget.text)),
          decoration: InputDecoration(
              hintText: 'District Search',
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: BorderSide(
                      color: themeManager.getColor(TypeOfWidget.text))),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: BorderSide(
                      color: themeManager.getColor(TypeOfWidget.button)))),
        ),
      ),
      messages != null ? messages : Container(),
      districtCards.length == 0
          ? Container()
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: new Row(children: districtCards)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Align(
            alignment: Alignment.bottomLeft,
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Exit',
                style: TextStyle(color: Colors.red),
              ),
            )),
        Align(
          alignment: Alignment.bottomRight,
          child: FlatButton(
            onPressed: () {
              _searchForState();
            },
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        )
      ]),
    ];
  }

  _searchForState() async {
    if (textController.text.length < 3) {
      messages = Container(
        child: Text(
          'Please enter 3 or more characters to get a complete search.',
          style: TextStyle(color: Colors.red),
        ),
        padding: EdgeInsets.all(10),
      );
    } else {
      districtsFromSearchQuery =
          await SkywardDistrictSearcher.searchForDistrictLinkFromState(
              dropDownVal, textController.text.trim());
      messages = null;
    }
    setState(() {});
  }

  customDialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 30.0, bottom: 16, left: 15, right: 16),
          margin: EdgeInsets.only(top: 20),
          decoration: new BoxDecoration(
            border: Border.all(color: themeManager.getColor(TypeOfWidget.text)),
            color: themeManager.getColor(TypeOfWidget.background),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: themeManager.getColor(TypeOfWidget.background),
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: createDialogBoxContents(context),
          ),
        )
      ],
    );
  }
}

class HuntyDialogForConfirmation extends HuntyDialog {
  final Function() runIfUserConfirms;
  final String btnTextForConfirmation;
  final String btnTextForCancel;
  final Function runIfUserCancels;

  HuntyDialogForConfirmation(
      {@required title,
      @required description,
      @required this.runIfUserConfirms,
      @required this.btnTextForConfirmation,
      @required this.btnTextForCancel,
      this.runIfUserCancels})
      : super(
            title: title,
            description: description,
            buttonText: 'buttonText error not needed');

  @override
  createDialogBoxContents(BuildContext context) {
    return <Widget>[
      Text(
        title,
        style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: themeManager.getColor(null)),
      ),
      SizedBox(height: 16.0),
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: themeManager.getColor(null)),
      ),
      SizedBox(
        height: 24.0,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Align(
            alignment: Alignment.bottomLeft,
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (runIfUserCancels != null) runIfUserCancels();
              },
              child: Text(
                btnTextForCancel,
                style: TextStyle(color: themeManager.getColor(null)),
              ),
            )),
        Align(
          alignment: Alignment.bottomRight,
          child: FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              runIfUserConfirms();
            },
            child: Text(btnTextForConfirmation,
                style: TextStyle(color: themeManager.getColor(null))),
          ),
        )
      ]),
      SizedBox(
        height: 32.0,
      ),
    ];
  }
}

class HuntyDialogForMoreText extends HuntyDialog {
  HuntyDialogForMoreText(
      {@required title, @required description, @required buttonText})
      : super(title: title, description: description, buttonText: buttonText);

  @override
  createDialogBoxContents(BuildContext context) {
    return <Widget>[
      Text(
        title,
        style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            color: themeManager.getColor(null)),
      ),
      SizedBox(height: 16.0),
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14.0, color: themeManager.getColor(null)),
      ),
      SizedBox(height: 24.0),
      Align(
        alignment: Alignment.bottomRight,
        child: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(buttonText,
              style:
                  TextStyle(color: themeManager.getColor(TypeOfWidget.button))),
        ),
      ),
    ];
  }
}

class HuntyDialogWithText extends HuntyDialog {
  final String hint;
  final TextEditingController textController;
  final Function okPressed;

  HuntyDialogWithText(
      {@required this.hint,
      @required this.textController,
      @required this.okPressed,
      @required title,
      @required description,
      @required buttonText})
      : super(title: title, description: description, buttonText: buttonText);

  @override
  createDialogBoxContents(BuildContext context) {
    textController.text = '';
    return <Widget>[
      Text(
        title,
        style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: themeManager.getColor(null)),
      ),
      SizedBox(height: 16.0),
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: themeManager.getColor(null)),
      ),
      Container(
        padding: EdgeInsets.only(top: 16),
        child: TextField(
          style: TextStyle(color: themeManager.getColor(null)),
          controller: textController,
          onSubmitted: (String a) {
            Navigator.of(context).pop();
            textController.text = a;
            okPressed();
          },
          decoration: InputDecoration(
              hintText: hint,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: BorderSide(
                      color: themeManager.getColor(TypeOfWidget.text))),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: BorderSide(
                      color: themeManager.getColor(TypeOfWidget.text)))),
        ),
      ),
      SizedBox(height: 16.0),
      Align(
        alignment: Alignment.bottomRight,
        child: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
            okPressed();
          },
          child: Text(
            buttonText,
            style: TextStyle(color: themeManager.getColor(null)),
          ),
        ),
      ),
    ];
  }
}

class HuntyDialogDebugCredentials extends HuntyDialog {
  final String hint;
  final TextEditingController textController2 = TextEditingController();

  HuntyDialogDebugCredentials(
      {@required this.hint,
      @required title,
      @required description,
      @required buttonText})
      : super(title: title, description: description, buttonText: buttonText);

  @override
  createDialogBoxContents(BuildContext context) {
    return <Widget>[
      Text(
        title,
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w700,
        ),
      ),
      SizedBox(height: 16.0),
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
      SizedBox(height: 10.0),
      Container(
        padding: EdgeInsets.only(top: 16),
        child: TextField(
          controller: textController2,
          onSubmitted: (String a) {
            textController2.text = a;
            sub(context);
          },
          decoration: InputDecoration(
              hintText: 'Command',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0))),
        ),
      ),
      SizedBox(height: 16.0),
      Align(
        alignment: Alignment.bottomRight,
        child: FlatButton(
          onPressed: () {
            sub(context);
          },
          child: Text(buttonText),
        ),
      ),
    ];
  }

  void sub(BuildContext context) async {
    bool isThere = true;

    if (isThere) {
      Navigator.of(context).pop();
      List split = textController2.text.split(' ');
      try {
        String termInd = (split[0]);
        int classInd = int.parse(split[1]);
        String newGrade = split[2];

        List<TeacherIDBox> techBox = [];
        for (GridBox gB in gradeBoxes) {
          if (gB is TeacherIDBox) techBox.add(gB);
        }

        print((gradeBoxes[gradeBoxes.indexOf(techBox[classInd]) +
            (int.parse(termInd))] as GradeBox));

        if (int.tryParse(termInd) != null)
          (gradeBoxes[gradeBoxes.indexOf(techBox[classInd]) +
                  (int.parse(termInd))] as GradeBox)
              .grade = newGrade;
      } catch (e) {
        print('Don\'t handle');
      }
    }
  }
}

// ignore: must_be_immutable
class HuntyDialogOfList extends HuntyDialog {
  final String hint;
  final Function okPressed;
  int indexOfValueChosen = 0;
  final List listOfValues;

  HuntyDialogOfList(
      {@required this.hint,
      @required this.okPressed,
      @required this.listOfValues,
      @required title,
      @required description,
      @required buttonText})
      : super(title: title, description: description, buttonText: buttonText);

  @override
  createDialogBoxContents(BuildContext context) {
    List<Widget> widgetList = [];
    for (int i = 0; i < listOfValues.length; i++) {
      widgetList.add(Container(
          child: Card(
        child: InkWell(
          onTap: () {
            indexOfValueChosen = i;
            Navigator.of(context).pop();
            if (okPressed != null) okPressed();
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Text(
              listOfValues[i].toString().toString(),
              style: TextStyle(
                  color: themeManager.getColor(TypeOfWidget.text),
                  fontSize: 15),
            ),
          ),
          splashColor: themeManager.getColor(TypeOfWidget.text),
        ),
        color: themeManager.getColor(TypeOfWidget.subBackground),
      )));
    }

    return <Widget>[
      Text(
        title,
        style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: themeManager.getColor(null)),
      ),
      SizedBox(height: 16.0),
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: themeManager.getColor(null)),
      ),
      Container(
          padding: EdgeInsets.only(top: 16),
          child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 100,
              ),
              child: ListView(children: widgetList))),
      SizedBox(height: 32.0),
    ];
  }
}
