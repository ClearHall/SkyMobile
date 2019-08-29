import 'package:flutter/material.dart';
import 'SkywardScraperAPI/SkywardDistrictSearcher.dart';
import 'SkywardScraperAPI/SkywardAPITypes.dart';
import 'main.dart';

class DialogColorMode {
  static Color getBackgroundColor() {
    return Colors.black;
  }

  static Color getDialogOrWidgetColor() {
    return Color.fromARGB(255, 21, 21, 21);
  }

  static Color getTextColor() {
    return Colors.white;
  }
}

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
      SizedBox(height: 24.0),
      Align(
        alignment: Alignment.bottomRight,
        child: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(buttonText),
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
            color: Colors.white,
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

class HuntyDialogLoading extends HuntyDialog {
  final String cancelText;
  final Function runWhenCancelled;
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
      SizedBox(height: 24.0),
      CircularProgressIndicator(),
      SizedBox(height: 24.0),
      Align(
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
            fontSize: 24.0, fontWeight: FontWeight.w700, color: Colors.blue),
      ),
      SizedBox(height: 16.0),
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: DialogColorMode.getTextColor(),
          fontSize: 16.0,
        ),
      ),
      SizedBox(height: 10.0),
      new Theme(
          data: Theme.of(context)
              .copyWith(canvasColor: DialogColorMode.getDialogOrWidgetColor()),
          child: DropdownButton<String>(
            items: SkywardDistrictSearcher.states
                .map<DropdownMenuItem<String>>((SkywardSearchState value) {
              return DropdownMenuItem<String>(
                value: value.stateID,
                child: Text(
                  value.stateName,
                  style: TextStyle(color: DialogColorMode.getTextColor()),
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
          style: TextStyle(color: DialogColorMode.getTextColor()),
//          onSubmitted: (String a) {
//            Navigator.of(context).pop();
//            okPressed();
//          },
          decoration: InputDecoration(
              hintText: 'District Search',
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: BorderSide(color: Colors.blue)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide:
                      BorderSide(color: DialogColorMode.getTextColor()))),
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
                style: TextStyle(color: Colors.orange),
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
            border: Border.all(color: Colors.orange),
            color: DialogColorMode.getDialogOrWidgetColor(),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: DialogColorMode.getBackgroundColor(),
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
  Function() runIfUserConfirms;
  String btnTextForConfirmation;
  String btnTextForCancel;

  HuntyDialogForConfirmation({
    @required title,
    @required description,
    @required this.runIfUserConfirms,
    @required this.btnTextForConfirmation,
    @required this.btnTextForCancel,
  }) : super(
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
      SizedBox(
        height: 24.0,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Align(
            alignment: Alignment.bottomLeft,
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(btnTextForCancel),
            )),
        Align(
          alignment: Alignment.bottomRight,
          child: FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              runIfUserConfirms();
            },
            child: Text(btnTextForConfirmation),
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
        ),
      ),
      SizedBox(height: 16.0),
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.0,
        ),
      ),
      SizedBox(height: 24.0),
      Align(
        alignment: Alignment.bottomRight,
        child: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(buttonText),
        ),
      ),
    ];
  }
}

class HuntyDialogWithText extends HuntyDialog {
  final String hint;
  var textController = TextEditingController();
  Function okPressed;

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
      Container(
        padding: EdgeInsets.only(top: 16),
        child: TextField(
          controller: textController,
          onSubmitted: (String a) {
            Navigator.of(context).pop();
            okPressed();
          },
          decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0))),
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
          child: Text(buttonText),
        ),
      ),
    ];
  }
}
