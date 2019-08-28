import 'package:flutter/material.dart';

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
  HuntyDialogLoading( this.cancelText, this.runWhenCancelled,
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
          child: Text(cancelText, style: TextStyle(color: Colors.red),),
        ),
      ),
    ];
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
